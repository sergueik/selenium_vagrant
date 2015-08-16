log 'Started execution custom nuget.exe downloader' do
  level :info
end

temp_dir ='C:\\Users\\vagrant\\AppData\\Local\\Temp'
scripts_dir = temp_dir.gsub('\\','/')
system = node['kernel']['machine'] == 'x86_64' ? 'win64' : 'win32'
download_url = node['custom_nuget']['download_url']
filename = node['custom_nuget']['filename']
package_title = 'console nuget client'
assemblies = %w/
CsQuery
Newtonsoft.Json
/

powershell "Download #{package_title}" do
  code <<-EOH

[string]$download_url = '#{download_url}'
[string]$local_file_path = '#{temp_dir}'
[string]$filename = '#{filename}'

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

# support relative paths
if (!(Split-Path -Parent $local_file_path) -or !(Test-Path -PathType Container (Split-Path -Parent $local_file_path))) {
  $local_file_path = Join-Path (Get-ScriptDirectory) (Split-Path -Leaf $local_file_path)
}

if (-not (Test-Path $local_file_path))
{
  throw "Folder ${local_path} does not Exist, file cannot be saved to"
}

$destination_file =  ('downloaded_file_{0}.exe' -f (Get-Random -Maximum 5000) )
Write-Host ("Downloading {0}`nSaving as {1}" -f $download_url,$destination_file)

$web_client = New-Object System.Net.WebClient
# TODO: proxy authentication

$web_client.DownloadFile($download_url,$destination_file)
# NOTE:
# Exception calling "DownloadFile" with "2" argument(s): "An exception occurred during a WebClient request."
# TODO: throw custom exception if unable to download the file.

Write-Host ("Moving {0} to {1}" -f $destination_file, $local_file_path)
$local_file = [System.IO.Path]::Combine($local_file_path, $filename)
copy-item -Destination $local_file -literalPath $destination_file
if ( -not (test-path -path $local_file )) { 
  Throw 'Failed to download file.'
}

  EOH
  not_if {::File.exists?("#{temp_dir}/#{filename}".gsub('\\', '/'))}
end

log "Completed download #{package_title}" do
  level :info
end

assemblies.each  do |assembly|
  powershell "Install #{assembly}" do
    code <<-EOH
      $framework = 'net40'
      pushd '#{temp_dir}'
      $env:PATH = "${env:PATH};#{temp_dir}"
      & nuget.exe install '#{assembly}' | out-file "#{temp_dir}\\nuget.log" -encoding ASCII -append
      pushd '#{temp_dir}'
      get-childitem -filter '#{assembly}.dll' -recurse | where-object { $_.PSPath -match '\\\\net40\\\\'} | copy-item -destination '.'
  EOH
  not_if {::File.exists?("#{temp_dir}/#{assembly}.dll".gsub('\\', '/'))}

  end
end

cookbook_file "#{scripts_dir}/get_task_scheduler_events.ps1" do
  source 'get_task_scheduler_events.ps1'
  path "#{scripts_dir}/get_task_scheduler_events.ps1"
end

powershell 'Execute uploaded script' do
  code <<-EOH
pushd '#{temp_dir}'
 . .\\get_task_scheduler_events.ps1
   EOH
end

log 'Completed execution uploaded script with Nuget-provided dependency.' do
  level :info
end

