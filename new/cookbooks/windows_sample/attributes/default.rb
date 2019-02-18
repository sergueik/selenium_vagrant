default['target_node']['script_version'] = '0.2'
# @basedir is the parent dir of .m2 e.g. for prod: '/opt/jenkins'
default['target_node']['basedir'] = 'c:\\Programdata\\jenkins'
# the high disk usage of drive @drive_id would trigger the purge script
default['target_node']['drive_id'] = 'C'
# Powershell script 'purge.ps1' is created under Programdata directory
default['target_node']['scriptdir'] = 'c:\\Programdata\script'

default['target_node']['account_username'] = 'vagrant'
# Disk usage over @high_percent is considered high
default['target_node']['high_percent'] = 3
# When do_purge is set to true, the bash script `purge.sh` is run in every chef run
# otherwise powershell script will examine the FreeSpace and Size  on aspeciifc DeviceId using WMI
default['target_node']['do_purge'] = true
default['target_node']['debug'] = true
# add a boolean flag to exercide -whatif option
default['target_node']['powershell_noop'] = true
