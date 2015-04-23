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
  run_command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' #{spoon_command}"
  taskname = 'Launch_selenium_grid_node'
  code <<-EOH

$level = 'HIGHEST'
$schedule = 'ONCE'
$time = '00:00' # required, irrrevant
$run_command = "#{run_command}"
$taskname = '#{taskname}'
<#
  $status = schtasks /query /TN $taskname| select-string -pattern "${taskname}"
  write-output $status
  if ($status -ne $null){
    write-host "${taskname} is present, deleting..."
   & SchTasks.exe /Delete /TN $taskname /F
    break 
  } else { 
    write-host "No ${taskname} is present..."
    break 
  }
#>
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

powershell  'Launch selenium-grid-node ie 10' do
  spoon_command = 'run base,spoonbrew/ie-selenium:10,spoonbrew/selenium-grid-node node ie 10'
  run_command = "'C:\\Program Files\\Spoon\\Cmd\\spoon.exe' #{spoon_command}"
  taskname = 'Launch_selenium_grid_node_ie_10'
  code <<-EOH

$level = 'HIGHEST'
$schedule = 'ONCE'
$time = '00:00' # required, irrrevant

$run_command = "#{run_command}"
$taskname = '#{taskname}'

<#
  $status = schtasks /query /TN $taskname| select-string -pattern "${taskname}"
  write-output $status
  if ($status -ne $null){
    write-host "${taskname} is present, deleting..."
   & SchTasks.exe /Delete /TN $taskname /F
    break 
  } else { 
    write-host "No ${taskname} is present..."
    break 
  }
#>
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

# http://www.msfn.org/board/topic/143463-prevent-password-expiration/
# wmic path Win32_UserAccount WHERE Name='MyUserName' set PasswordExpires=true
# net accounts /maxpwage:90
# net user [username] /expires:06/30/11

# $EXPIRY = gwmi win32_USERACCOUNT | Where-Object {$_.NAME -eq "MrJinje"};$EXPIRY.PasswordExpires = $False;$EXPIRY.Put()
# direct execution hangs

