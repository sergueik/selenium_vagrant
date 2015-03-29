ystem = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'

source_url = node['spoon']['spoon-plugin']['url']
username = node['spoon']['username']
password = node['spoon']['password']

dest_file = 'spoon-plugin.exe'
temp_path = 'C:\\temp'
dest_file_path = "#{temp_path}/#{dest_file}"

log 'Starting Download' do
  level :info
end

# Create temp folder
directory temp_path  do
  action :create
end

powershell "Download Spoon Plugin #{source_url}" do
  code <<-EOH

<#
  $username = 'kouzmine_serguei@yahoo.com'
  $powershell_source_url = "https://start-c.spoon.net/layers/setup/3.33.539/spoon-plugin.exe"
  $dest_file = 'spoon-plugin.exe'
  $dest_file_path = 'C:\\temp' 
  $password = 'I/z00mscr'
#>

  [string]$username = '#{username}'
  [string]$source_url = '#{source_url}'
  [string]$dest_file = '#{dest_file}'
  [string]$dest_file_path = '#{dest_file_path}'
  [string]$password = '#{password}'
  [bool]$use_proxy = $false

Write-Host "Probing credentials"

  [system.Net.WebRequest]$request = [system.Net.WebRequest]::Create($source_url)
  try {
    [string]$encoded = [System.Convert]::ToBase64String([System.Text.Encoding]::GetEncoding('ASCII').GetBytes(($username + ':' + $password)))
    $request.Headers.Add('Authorization','Basic ' + $encoded)
  } catch [argumentexception]{

  }
  # TODO -  statuscode
  if ($PSBoundParameters['use_proxy']) {
    Write-Host ('Use Proxy: "{0}"' -f $proxy.Address)
    $request.proxy = $proxy
    $request.useDefaultCredentials = $true
  }

Write-Host "Downloading ${dest_file}"

$webclient = new-object System.Net.WebClient
$credCache = new-object System.Net.CredentialCache
$creds = new-object System.Net.NetworkCredential($username,$password)
$credCache.Add($source_url, "Basic", $creds)
$webclient.Credentials = $credCache
[void]((New-Object Net.WebClient).DownloadFile($source_url,$dest_file_path))

<#
"The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."

#>
  EOH
  not_if { ::File.exists?(dest_file_path) }
end

log 'Complete Download' do
  level :info
end
