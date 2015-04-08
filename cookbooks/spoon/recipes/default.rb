system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'

source_url = node['spoon']['spoon-plugin']['url']
username = node['spoon']['username']
password = node['spoon']['password']
account_username   = 'vagrant'
account_userdomain = 'windows7'
dest_file = 'spoon-plugin.exe'
job_xml   = 'install_spool_plugin.xml'
temp_path = 'C:\\temp'
dest_file_path = "#{temp_path}/#{dest_file}"

log "Starting Download #{dest_file}" do
  level :info
end

# Create temp folder
directory temp_path  do
  action :create
end

powershell "Download Spoon Plugin #{source_url}" do
  code <<-EOH

  [string]$username = '#{username}'
  [string]$source_url = '#{source_url}'
  [string]$dest_file = '#{dest_file}'
  [string]$dest_file_path = '#{dest_file_path}'
  [string]$password = '#{password}'
  [bool]$use_proxy = $false

# http://poshcode.org/1942
function assert {
  [CmdletBinding()]
  param(
    [Parameter(Position = 0,ParameterSetName = 'Script',Mandatory = $true)]
    [scriptblock]$Script,
    [Parameter(Position = 0,ParameterSetName = 'Condition',Mandatory = $true)]
    [bool]$Condition,
    [Parameter(Position = 1,Mandatory = $true)]
    [string]$message)

  $message = "ASSERT FAILED: $message"
  if ($PSCmdlet.ParameterSetName -eq 'Script') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = & $Script
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }
  if ($PSCmdlet.ParameterSetName -eq 'Condition') {
    try {
      $ErrorActionPreference = 'STOP'
      $success = $Condition
    } catch {
      $success = $false
      $message = "$message`nEXCEPTION THROWN: $($_.Exception.GetType().FullName)"
    }
  }

  if (!$success) {
    throw $message
  }
}


Write-Host "Probing credentials"

  [system.Net.WebRequest]$request = [system.Net.WebRequest]::Create($source_url)
  try {
    [string]$encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::GetEncoding('ASCII').GetBytes(($username + ':' + $password)))
    $request.Headers.Add('Authorization','Basic ' + $encoded)
  } catch [argumentexception]{

  }
  # TODO -  statuscode
  if ($PSBoundParameters['use_proxy']) {

    # Use current user NTLM credentials do deal with corporate firewall
    $proxy_address = (Get-ItemProperty 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings').ProxyServer

    if ($proxy_address -eq $null) {
      $proxy_address = (Get-ItemProperty 'HKCU:\\Software\\Microsoft\\Windows\\CurrentVersion\\Internet Settings').AutoConfigURL
    }

    if ($proxy_address -eq $null) {
      # write a hard coded proxy address here 
      $proxy_address = 'http://proxy.carnival.com:8080/array.dll?Get.Routing.Script'
    }

    $proxy = New-Object System.Net.WebProxy
    $proxy.Address = $proxy_address
    Write-Host ("Probing {0}" -f $proxy.Address)
    $proxy.useDefaultCredentials = $true


    Write-Host ('Use Proxy: "{0}"' -f $proxy.Address)
    $request.proxy = $proxy
    $request.useDefaultCredentials = $true
  }
<#
  $sleep_interval = 10
  $max_retries = 5

  for ($i = 0; $i -ne $max_retries; $i++) {

    Write-Host ('Try {0}' -f $i)

    try {
#>
     $response = $request.GetResponse()

assert -Script { ($response.StatusCode -eq 'OK') } -Message ( 'bad response status code: {0}' -f $response.StatusCode )
<#
 NOTE: when using Download button from  https://spoon.net, Linux host platform is rejected with the dialog:
 "Spoon applications currently only launch on Windows PCs and tablets, 
 but support for Mac is coming soon! "
#>
Write-Host "Downloading ${dest_file}"

$webclient = new-object System.Net.WebClient
$credCache = new-object System.Net.CredentialCache
$creds = new-object System.Net.NetworkCredential($username,$password)
$credCache.Add($source_url, "Basic", $creds)
$webclient.Credentials = $credCache
[void]((New-Object Net.WebClient).DownloadFile($source_url,$dest_file_path))

<#
NOTE: cannot use https:

"The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."

#>
  EOH
  not_if { ::File.exists?(dest_file_path) }
end

log 'Complete Download' do
  level :info
end


template ("#{temp_path}/#{job_xml}") do 
  source 'install_spoon_plugin.erb'
  variables(
    :account_username => account_username,
    :account_userdomain => account_userdomain,
    :program => dest_file, 
    :path  => temp_path 
    ) 
 action :create_if_missing
end 

powershell "Install Spoon Plugin #{dest_file}" do
  
code <<-EOH
$name = 'install spoon plugin'
# https://github.com/opscode-cookbooks/windows
# The windows_task LWRP requires Windows Server 2008 due to its API usage.
# http://blogs.technet.com/b/heyscriptingguy/archive/2013/11/23/using-scheduled-tasks-and-scheduled-jobs-in-powershell.aspx
# http://www.geoffhudik.com/tech/2011/10/11/start-scheduled-task-and-wait-on-completion-with-powershell.html
$name = 'install spoon plugin'

& schtasks /Delete /F /TN $name
write-output "Starting task '${name}'"

& schtasks /Create /TN $name /XML "#{temp_path}\\#{job_xml}"
& schtasks /Run /TN $name
write-output "Waiting for status of the task '${name}'"
start-sleep -second 1

while($true){
   $status = schtasks /query /TN $name| select-string -pattern "${name}"
write-output $status

if ($status.tostring() -match '(Running|Ready)'){
  write-host "${name} is running..."
  break 
} else { 
  write-host "${name} is not yet running..."
}
  start-sleep -milliseconds 1000
}

while($true){
  $status = schtasks /query /TN $name|select-string  -pattern "${name}"
if ($status.tostring() -match 'Ready'){
  write-host "${name} is ready."
  break 
} else { 
  write-host "${name} is not yet ready."
}
  start-sleep -milliseconds 1000
}
& schtasks /Delete /F /TN $name

$env:PATH="${env:PATH};C:\\Program Files\\Spoon\\Cmd"

# & spoon help
# & spoon login kouzmine_serguei@yahoo.com "I/z00mscr"
#& spoon pull gnu/wget

# Run the latest Firefox image
#& spoon pull mozilla/firefox:34
## & spoon pull oracle/jdk:7.65

# Start the container
# spoon run -w="C:\" -d --startup-file=cmd.exe git/git,oracle/jdk7
# mkdir java & cd java
# TODO issue wget command for selenium-server-standalone-2.44.0.jar
  EOH
  only_if { ::File.exists?( "#{temp_path}/#{job_xml}" ) }
  #
  not_if { ::Registry.value_exists?('HKCU\Software\Code Systems\Spoon','Id')}
end

shared_folder = '\\\\VBOXSVR\\v-csdb-2'
sample_image_tag = 'gnu/wget'
powershell "Pulling Spoon Image: #{sample_image_tag}" do
code <<-EOH

& spoon help
& spoon login #{username} "#{password}"
# & spoon login kouzmine_serguei@yahoo.com "I/z00mscr"
& spoon pull #{sample_image_tag}
  EOH
  only_if  { ::File.exists?( "#{shared_folder}" ) }
end
spoon_box_images = %w|
spoonbrew%2Fbase%3A1
spoonbrew%2Fie-selenium%3A9
gnu%2Fwget
oracle%2Fjre-core%3A8.25
selenium-server-standalone%3A2.43
|
spoon_box_images.each do |spoon_box_image|
powershell "Importing Spoon Image: #{spoon_box_image}" do
code <<-EOH
& spoon login #{username} "#{password}"
spoon import --name=spoonbrew/ie-selenium:9 --overwrite svm #{shared_folder}\\#{spoon_box_image}
  EOH
  only_if  { ::File.exists?( "#{shared_folder}\\#{spoon_box_image}" ) }
end

end

# stackoverflow.com/questions/26583733/chef-powershell-output-capture-into-attribute-in-latest-chef-12 
# run sample spoon commands: https://spoon.net/docs/getting-started/samples
# NOTE choose lean images first from https://spoon.net/hub
# Start the container
# spoon run -w="C:\" -d --startup-file=cmd.exe git/git,oracle/jdk7
# mkdir java & cd java
# https://spoon.net/hub/bharathy89/selenium-Firefox
# http://www.hurryupandwait.io/blog/windows-containers-package-your-apps-and-bootstrap-your-chef-nodes-with-spoonnet
