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
shared_folder = '\\\\VBOXSVR\\v-csdb-2'
sample_image_tag = 'spoonbrew/base:1'
import_shared_images = false
import_browser_images = false

spoon_shared_images = %w|
    spoonbrew%2Fbase%3A1
    gnu%2Fwget
    oracle%2Fjre-core%3A8.25
    selenium-server-standalone%3A2.43
    selenium-chrome-driver
    selenium-ie-driver
    selenium-grid-plugin%3A201502271240
|

spoon_box_browser_images = %w|
    spoonbrew%2Fie-selenium%3A9
    spoonbrew%2Fie-selenium%3A10
    spoonbrew%2Fie-selenium%3A11
|

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


Write-Host 'Probing credentials'

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
    Write-Host ('Probing {0}' -f $proxy.Address)
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

log 'Complete spoon-plugin Download' do
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

$name = 'Install spoon plugin'
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


  EOH
  only_if { ::File.exists?( "#{temp_path}/#{job_xml}" ) }
  # skip if spoon is installed
  not_if { ::Registry.value_exists?('HKCU\Software\Code Systems\Spoon','Id')}
end

powershell "Pulling Spoon Image: #{sample_image_tag}" do
  code <<-EOH
  $env:PATH="${env:PATH};C:\\Program Files\\Spoon\\Cmd"
  & spoon.exe help
  & spoon.exe login #{username} "#{password}"
  & spoon.exe pull #{sample_image_tag}
  EOH
  only_if  { ::File.exists?( "#{shared_folder}" ) }
end
# Store URL-encoded image names in the filenames
# TODO provide a guard 
# not_if "spoon.exe images --no-truncace | findstr '#{spoon_image_tag}' "
if import_shared_images
  spoon_shared_images.each do |spoon_box_image|
    spoon_image_tag = spoon_box_image.gsub('%3A',':').gsub('%2F','/')
    powershell "Importing Spoon Image: #{spoon_image_tag}" do
      code <<-EOH
      & spoon.exe login #{username} "#{password}"
      & spoon.exe import --name=#{spoon_image_tag} --overwrite svm #{shared_folder}\\#{spoon_box_image}
      EOH
      only_if  { ::File.exists?( "#{shared_folder}\\#{spoon_box_image}" ) }
    end
  end
end

if import_browser_images
  spoon_browser_images.each do |spoon_box_image|
    spoon_image_tag = spoon_box_image.gsub('%3A',':').gsub('%2F','/')
    powershell "Importing Spoon Image: #{spoon_image_tag}" do
      code <<-EOH
      & spoon.exe login #{username} "#{password}"
      & spoon.exe import --name=#{spoon_image_tag} --overwrite svm #{shared_folder}\\#{spoon_box_image}
      EOH
      only_if  { ::File.exists?( "#{shared_folder}\\#{spoon_box_image}" ) }
    end
  end
end
# https://technet.microsoft.com/en-us/library/cc725744.aspx

# NOTE: batch resource requires Chef 11.6.0 or later
# The box image used has chef-windows-10.34.6-1.windows
# --detach  does not seem to work
# https://technet.microsoft.com/en-us/library/dd347721.aspx
# https://github.com/chef/chef/issues/2348
# Start-Transcript [[-Path] <string>] [-Append] [-Force] [-NoClobber] [-Confirm] [-WhatIf] [<CommonParameters>]
powershell 'Launch selenium-grid' do
  run_command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' run base,selenium-grid"
  taskname = 'Launch_selenium_grid'

  code <<-EOH

$level = 'HIGHEST'
$schedule = 'ONCE'
$time = '00:00' 
# $run_command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' run base,selenium-grid"
$run_command = "#{run_command}"
$taskname = '#{taskname}'
& SchTasks.exe /Delete /TN $taskname /F
# Note: /IT
& SchTasks.exe /Create  /TN $taskname /RL $level /TR $run_command /SC $schedule /ST $time
& SchTasks.exe /Run /TN $taskname

write-output "Waiting for status of the task '${taskname}'"

start-sleep -second 1

while($true){
  $status = schtasks /query /TN $taskname| select-string -pattern "${taskname}"
  write-output $status
  if ($status.tostring() -match '(Running|Ready)'){
    write-host "${taskname} is running..."
    break 
  } else { 
    write-host "${taskname} is not yet running..."
  }
  start-sleep -milliseconds 1000
}

  EOH
  action  :run
end

powershell  'Launch selenium-grid-node' do
  run_command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' run base,spoonbrew/ie-selenium:9,selenium-grid-node node ie 9"
  taskname = 'Launch_selenium_grid_node'
  code <<-EOH

$level = 'HIGHEST'
$schedule = 'ONCE'
$time = '00:00' # required, irrrevant

$run_command = "#{run_command}"
$taskname = '#{taskname}'

& SchTasks.exe /Delete /TN $taskname /F
& SchTasks.exe /Create  /TN $taskname /RL $level /TR $run_command /SC $schedule /ST $time
& SchTasks.exe /Run /TN $taskname

while($true){
  $status = schtasks /query /TN $taskname| select-string -pattern "${taskname}"
  write-output $status
  if ($status.tostring() -match '(Running|Ready)'){
    write-host "${taskname} is running..."
    break 
  } else { 
    write-host "${taskname} is not yet running..."
  }
  start-sleep -milliseconds 1000
}


  EOH
  action  :run
end

log 'Completed install and launch Spoon Selenium Grid.' do
  level :info
end

