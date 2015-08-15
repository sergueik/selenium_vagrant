# origin:
# http://poshcode.org/4332
# http://poshcode.org/4331
param(
  [string]$url,
  [string]$local_path
)

if (!(Split-Path -Parent $local_path) -or !(Test-Path -PathType Container (Split-Path -Parent $local_path))) {
  $local_path = Join-Path $pwd (Split-Path -Leaf $local_path)
}

if (-not (Test-Path $local_path))
{
  throw "Folder ${local_path} does not Exist, file cannot be saved to"
}

Write-Output ("Downloading {0}`nSaving at {1}" -f $url,$local_path)
$web_client = New-Object System.Net.WebClient
# TODO: proxy authentication

$web_client.DownloadFile($url,$local_path)

# TODO: throw exception if unable to download the file.


