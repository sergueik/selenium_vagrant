
# when downloading from https://spoon.net/
# Spoon applications currently only launch on Windows PCs and tablets, but support for Mac is coming soon!
Write-Host "Downloading spoon-plugin.exe"
(New-Object Net.WebClient).DownloadFile("http://start-c.spoon.net/layers/setup/3.33.8.488/spoon-plugin.exe","$env:TEMP/spoon-plugin.exe")

# Solution 1:
# PRO: easy installation with the following command
# CONS: path is not set in already logged on interactive session
# Write-Host "Installing spoon-plugin.exe"
# . "$env:TEMP\spoon-plugin.exe"
# Write-Host "Please log off and log on again to update PATH"

# Solution 2:
# PRO: run installation in interactive session, so PATH is updated
# CONS: heavy complex solution, xml needed for battery mode of host

# create a Task Scheduler task which is also able to run in battery mode due
# to host notebooks working in battery mode. This complicates the whole script
# from a one liner to a fat XML - good heaven.

$xml = @"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>2014-03-27T13:53:05</Date>
    <Author>vagrant</Author>
  </RegistrationInfo>
  <Triggers>
    <TimeTrigger>
      <StartBoundary>2014-03-27T00:00:00</StartBoundary>
      <Enabled>true</Enabled>
    </TimeTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>vagrant</UserId>
      <LogonType>InteractiveToken</LogonType>
      <RunLevel>LeastPrivilege</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>false</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <IdleSettings>
      <StopOnIdleEnd>true</StopOnIdleEnd>
      <RestartOnIdle>false</RestartOnIdle>
    </IdleSettings>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <WakeToRun>false</WakeToRun>
    <ExecutionTimeLimit>P3D</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>$env:TEMP\spoon-plugin.exe</Command>
      <Arguments></Arguments>
    </Exec>
  </Actions>
</Task>
"@

$XmlFile = $env:Temp + "\InstallSpoon.xml"
Write-Host "Write Task to $XmlFile"
$xml | Out-File $XmlFile

& schtasks /Delete /F /TN InstallSpoon
& schtasks /Create /TN InstallSpoon /XML $XmlFile
& schtasks /Run /TN InstallSpoon



