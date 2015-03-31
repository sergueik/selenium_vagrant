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
& schtasks /Delete /F /TN $name
& schtasks /Create /TN $name /XML "#{temp_path}\\#{job_xml}"
& schtasks /Run /TN $name
# TODO: Invoke-Expression -Command 
# TODO: block until
#
# schtasks /query /tn "install spoon plugin"
# ======================================== ====================== ===============
# install spoon plugin                     N/A                    Running
# ======================================== ====================== ===============
#install spoon plugin                     N/A                    Ready
# & schtasks /Delete /F /TN $name
  EOH
  only_if { ::File.exists?( "#{temp_path}/#{job_xml}" ) }
  not_if { ::Registry.value_exists?('HKCU\Software\Code Systems\Spoon','Id')}
end
# stackoverflow.com/questions/26583733/chef-powershell-output-capture-into-attribute-in-latest-chef-12 

