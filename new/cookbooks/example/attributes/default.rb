default['target_node']['unix']['script_version'] = '0.4'

# @basedir is the parent dir of .m2 e.g. for prod: '/opt/jenkins'
default['target_node']['unix']['basedir'] = '/home/vagrant'
# the high disk usage of @disk would trigger the purge script
default['target_node']['unix']['disk'] = '/dev/sda1'
# Bash script 'purge.sh' is created under account_username home directory
default['target_node']['unix']['account_username'] = 'vagrant'
# Disk usage over @high_percent is considered high
default['target_node']['unix']['high_percent'] = 3
# When do_purge is set to true, the bash script `purge.sh` is run in every chef run
# otherwise it will examine the df output for filesystem mounted to @mount_dir
default['target_node']['unix']['do_purge'] = true
# note : the unix and windows versions  of the cookbook are completely independent
default['target_node']['windows']['script_version'] = '0.4'
# @basedir is the parent dir of .m2 e.g. for prod: '/opt/jenkins'
# a.k.a. ALLUSERSPROFILE
default['target_node']['windows']['basedir'] = 'c:\\Programdata\\jenkins'
# the high disk usage of drive @drive_id would trigger the purge script
default['target_node']['windows']['drive_id'] = 'C:'
# Powershell script 'purge.ps1' is created under Programdata directory
default['target_node']['windows']['scriptdir'] = 'c:\\Programdata\script'

default['target_node']['windows']['account_username'] = 'vagrant'
# Disk usage over @high_percent is considered high
default['target_node']['windows']['high_percent'] = 3
# When do_purge is set to true, the bash script `purge.sh` is run in every chef run
# otherwise powershell script will examine the FreeSpace and Size  on aspeciifc DeviceId using WMI
default['target_node']['windows']['powershell_noop'] = false
default['target_node']['windows']['do_purge'] = true

# toggle between single and multi drive purge
default['target_node']['windows']['multidrive'] = true
# NOTE: data structures look terrible in Chef attributes
default['target_node']['windows']['drive_ids'] = [
  'C:',
  'E:'
]
default['target_node']['windows']['basedirs'] = {
  'C:' => 'C:\\Programdata\\jenkins',
  'E:' => 'E:\\Jenkins',
  'D:' => 'D:\\Jenkins'
}
# unused drive_ids will be ignored
default['target_node']['windows']['high_percents'] = {
  'C:' => 90,
  'D:' => 10,
  'E:' => 25
}

# the next configuration entry is shared between platforms
# enable as needed
default['target_node']['debug'] = false
