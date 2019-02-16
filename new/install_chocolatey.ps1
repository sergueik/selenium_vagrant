# origin: https://github.com/tzehon/vagrant-windows

$appPath = "${env:ProgramData}\chocolateybin"
if ([Environment]::GetEnvironmentVariable('CHOCOLATEYINSTALL', [System.EnvironmentVariableTarget]::Machine) -ne $null) {
  write-output 'Chocolatey already installed.'
  exit 0
}

# Put chocolatey on the MACHINE path,
# since Vagrant does not have access to user environment variables
# NOTE: if the USER path is set it needs to be modified as well otherwise it will shadow the SYSTEM PATH for interactive user

$envPath = [Environment]::GetEnvironmentVariable('PATH', [System.EnvironmentVariableTarget]::Machine)
if (!$envPath.ToLower().Contains($appPath.ToLower())) {

  Write-Host "MACHINE PATH environment variable does not have `'$appPath`' in it. Adding..."
  $pathSeparator = ';'
  $hasTrailingPathSeparator = $envPath -ne $null -and $envPath.endswith($pathSeparator)
  if (!$hasTrailingPathSeparator -and $envPath -ne $null) { $appPath = $pathSeparator + $appPath }
  if (!$appPath.endswith($pathSeparator)) { $appPath += $pathSeparator }

  [environment]::SetEnvironmentVariable('PATH',$envPath + $appPath,[System.EnvironmentVariableTarget]::Machine)
}

$env:Path += ";$appPath"

if (!(Test-Path $appPath)) {
  # Install chocolatey
  write-host 'Install Chocolatey'
  invoke-expression ((new-object Net.WebClient).DownloadString('http://chocolatey.org/install.ps1'))
}

