Param (
  [string]$download_url,
  [string]$local_file_path,
  [string]$filename 
)


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

pushd $env:temp

# support relative paths
if (!(Split-Path -Parent $local_file_path) -or !(Test-Path -PathType Container (Split-Path -Parent $local_file_path))) {
  $local_file_path = Join-Path (Get-ScriptDirectory) (Split-Path -Leaf $local_file_path)
}

if (-not (Test-Path $local_file_path))
{
  throw "Folder ${local_path} does not Exist, file cannot be saved to"
}

$destination_file =  [System.IO.Path]::Combine($env:temp, ('downloaded_file_{0}.exe' -f (Get-Random -Maximum 5000) ))
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
popd
