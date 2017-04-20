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
shared_folder = '\\\\VBOXSVR\\v-csdb-2'  # use data-bags share
sample_image_tag = 'spoonbrew/base:1'
import_shared_images = false
import_browser_images = false

powershell "Logon to spoon" do
  code <<-EOH
  $env:PATH="${env:PATH};C:\\Program Files\\Spoon\\Cmd"
  & spoon.exe login #{username} "#{password}"
  EOH
  # only if spoon-plugin is installed
  only_if  { ::Registry.value_exists?('HKCU\Software\Code Systems\Spoon','Id')}
end

# removed download and install selenium-plugin.exe and pull and import images: repackaged the box with the spoon images already present.
# Get-ScheduledTask relies on underlying features of the OS that Windows 7 doesn't have, 
# so there is no way to run the cmdlet on that OS, even with PowerShell v4.
# http://stackoverflow.com/questions/26658249/powershell-4-get-scheduledtask-and-windows


# https://technet.microsoft.com/en-us/library/cc725744.aspx

# NOTE: batch resource requires Chef 11.6.0 or later
# The box image used has chef-windows-10.34.6-1.windows
# TODO spoon stop <running containers>
powershell  'Launch selenium-grid' do
  spoon_command = 'run base,spoonbrew/selenium-grid'
  command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' #{spoon_command}"
  taskname = 'Launch_selenium_grid_node'
  code <<-EOH

$level = 'HIGHEST'
$schedule = 'ONCE'
$time = '00:00' # required, irrrevant
$command = "#{command}"
$taskname = '#{taskname}'
if ($command -eq ''){
  $command = 'notepad.exe'
}
$delete_existing_schedules = $true

function log{
param(
  [string]$message,
  [string]$log_file  = '<%=@log-%>'
 )
    write-host $message
    write-output $message | out-file $log_file -append -encoding ascii
}

log -message ('Launching task for "{0}"' -f $command)
$env:PATH = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)

if ($delete_existing_schedules) {
  $status = schtasks /query /TN $taskname| select-string -pattern "${taskname}" 
  log $status
  if ($status -ne $null){
   log -message "${taskname} is present, deleting..."
   & schtasks /Delete /TN $taskname /F
  } else { 
    write-host "No ${taskname} is present...ignoring"
    log -message "No ${taskname} is present...ignoring"
  }
}
log ('Creating "{0}"' -f $taskname )
& schtasks /Create  /TN $taskname /RL $level /TR $command /SC $schedule /ST $time
log ('Starting "{0}"' -f $taskname )
& schtasks /Run /TN $taskname
$count = 1
$max_count = 100
$running = $false
$finished = $false
while($count -le $max_count ){
  $count ++
  $status = & schtasks /query /TN $taskname| select-string -pattern "${taskname}"
  log $status
  if ($status.tostring() -match '(Could not)'){
    log "WARNING: ${taskname} has failed..."
    break 
  } elseif ($status.tostring() -match '(Ready)'){
    log "NOTICE: ${taskname} is ready..."
    $running = $true
  } elseif ($status.tostring() -match '(Running)'){
    log "SUCCESS: ${taskname} is running..."
    $running = $true
    break 
  } else { 
    log "WARNING: ${taskname} is not yet running..."
  }
  start-sleep -milliseconds 1000
}
# TODO : time management
if ($running){
  log "NOTICE: waiting for running ${taskname} to complete..."
  $count = 1
  $max_count = 10
  while($count -le $max_count ){
    $count ++
    $status = & schtasks /query /TN $taskname| select-string -pattern "${taskname}"
    log $status
    if ($status.tostring() -match '(Could not|Failed)'){
      log "WARNING: ${taskname} has failed..."
      break 
    } elseif ($status.tostring() -match '(Running)'){
      log "NOTICE: ${taskname} is running..."
    } else { 
      log "SUCCESS: ${taskname} is finished..."
      $finished = $true
      break 
    }
    start-sleep -milliseconds 60000
 }
}
log 'Complete'



& SchTasks.exe /Create  /TN $taskname /RL $level /TR $command /SC $schedule /ST $time
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
## WARNING - redundant code
powershell  'Launch selenium-grid-node ie 10' do
  spoon_command = 'run base,spoonbrew/ie-selenium:10,spoonbrew/selenium-grid-node node ie 10'
  command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' #{spoon_command}"
  taskname = 'Launch_selenium_grid_node_ie_10'
  code <<-EOH
$level = 'HIGHEST'
$schedule = 'ONCE'
$time = '00:00' # required, irrrevant
$command = "#{command}"
$taskname = '#{taskname}'
if ($command -eq ''){
  $command = 'notepad.exe'
}
$delete_existing_schedules = $true

function log{
param(
  [string]$message,
  [string]$log_file  = '<%=@log-%>'
 )
    write-host $message
    write-output $message | out-file $log_file -append -encoding ascii
}

log -message ('Launching task for "{0}"' -f $command)
$env:PATH = [Environment]::GetEnvironmentVariable('Path', [System.EnvironmentVariableTarget]::Machine)

if ($delete_existing_schedules) {
  $status = schtasks /query /TN $taskname| select-string -pattern "${taskname}" 
  log $status
  if ($status -ne $null){
   log -message "${taskname} is present, deleting..."
   & schtasks /Delete /TN $taskname /F
  } else { 
    write-host "No ${taskname} is present...ignoring"
    log -message "No ${taskname} is present...ignoring"
  }
}
log ('Creating "{0}"' -f $taskname )
& schtasks /Create  /TN $taskname /RL $level /TR $command /SC $schedule /ST $time
log ('Starting "{0}"' -f $taskname )
& schtasks /Run /TN $taskname
$count = 1
$max_count = 100
$running = $false
$finished = $false
while($count -le $max_count ){
  $count ++
  $status = & schtasks /query /TN $taskname| select-string -pattern "${taskname}"
  log $status
  if ($status.tostring() -match '(Could not)'){
    log "WARNING: ${taskname} has failed..."
    break 
  } elseif ($status.tostring() -match '(Ready)'){
    log "NOTICE: ${taskname} is ready..."
    $running = $true
  } elseif ($status.tostring() -match '(Running)'){
    log "SUCCESS: ${taskname} is running..."
    $running = $true
    break 
  } else { 
    log "WARNING: ${taskname} is not yet running..."
  }
  start-sleep -milliseconds 1000
}
# TODO : time management
if ($running){
  log "NOTICE: waiting for running ${taskname} to complete..."
  $count = 1
  $max_count = 10
  while($count -le $max_count ){
    $count ++
    $status = & schtasks /query /TN $taskname| select-string -pattern "${taskname}"
    log $status
    if ($status.tostring() -match '(Could not|Failed)'){
      log "WARNING: ${taskname} has failed..."
      break 
    } elseif ($status.tostring() -match '(Running)'){
      log "NOTICE: ${taskname} is running..."
    } else { 
      log "SUCCESS: ${taskname} is finished..."
      $finished = $true
      break 
    }
    start-sleep -milliseconds 60000
 }
}
log 'Complete'



& SchTasks.exe /Create  /TN $taskname /RL $level /TR $command /SC $schedule /ST $time
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

# http://www.msfn.org/board/topic/143463-prevent-password-expiration/
# wmic path Win32_UserAccount WHERE Name='MyUserName' set PasswordExpires=true
# net accounts /maxpwage:90
# net user [username] /expires:06/30/11

# $EXPIRY = gwmi win32_USERACCOUNT | Where-Object {$_.NAME -eq "MrJinje"};$EXPIRY.PasswordExpires = $False;$EXPIRY.Put()
# direct execution hangs

