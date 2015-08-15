log 'Started execution custom nuget.exe downloader' do
  level :info
end

package = '' 

# install Nuget. There seems to be no msi package
# this happens to be cwd of the Powershell script
temp_dir  ='C:\\Users\\vagrant\\AppData\\Local\\Temp'
system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
filename_url = node['custom_nuget']['url']

powershell 'Download console nuget client' do
  code <<-EOH

# http://poshcode.org/4332
# http://poshcode.org/4331

[string]$url = "#{filename_url}"
[string]$local_path = "#{temp_dir}"

# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
function Get-ScriptDirectory {
  $Invocation = (Get-Variable MyInvocation -Scope 1).Value
  if ($Invocation.PSScriptRoot) {
    $Invocation.PSScriptRoot
  }
  elseif ($Invocation.MyCommand.Path) {
    Split-Path $Invocation.MyCommand.Path
  } else {
    $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf(''))
  }
}

if (!(Split-Path -Parent $local_path) -or !(Test-Path -PathType Container (Split-Path -Parent $local_path))) {
  $local_path = Join-Path (Get-ScriptDirectory) (Split-Path -Leaf $local_path)
}

if (-not (Test-Path $local_path))
{
  throw "Folder ${local_path} does not Exist, file cannot be saved to"
}


<#
Exception calling "DownloadFile" with "2" argument(s): "An exception occurred during a WebClient request."
#>

$destination_file =  ('downloaded_file_{0}.exe' -f (Get-Random -Maximum 5000) )
Write-Host ("Downloading {0}`nSaving at {1}" -f $url,$destination_file)
$web_client = New-Object System.Net.WebClient
# TODO: proxy authentication

$web_client.DownloadFile($url,$destination_file)
# TODO: throw exception if unable to download the file.

Write-Host ("Moving {0} to {1}" -f $destination_file, $local_path)
copy-item -Destination $local_path -literalPath $destination_file


  EOH
  # only if nuget is not installed
  # only_if  { ::Registry.value_exists?('HKCU\Software\Code Systems\Spoon','Id')}
end

log 'Completed execution various custom powershell scripts.' do
  level :info
end
