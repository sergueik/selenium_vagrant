default['target_node']['script_version'] = '0.3'
# @basedir is the parent dir of .m2 e.g. for prod: '/opt/jenkins'
# a.k.a. ALLUSERSPROFILE
default['target_node']['basedir'] = 'c:\\Programdata\\jenkins'
# the high disk usage of drive @drive_id would trigger the purge script
default['target_node']['drive_id'] = 'C:'
# Powershell script 'purge.ps1' is created under Programdata directory
default['target_node']['scriptdir'] = 'c:\\Programdata\script'

default['target_node']['account_username'] = 'vagrant'
# Disk usage over @high_percent is considered high
default['target_node']['high_percent'] = 3
# When do_purge is set to true, the bash script `purge.sh` is run in every chef run
# otherwise powershell script will examine the FreeSpace and Size  on aspeciifc DeviceId using WMI
# NOTE: set value to Powershell's 'boolean' string value - cannot use Ruby boolean due to lack of conversion
# default['target_node']['do_purge'] = '$true'
default['target_node']['do_purge'] = true
default['target_node']['debug'] = true
# PAss a sepaate boolean value to exercide -whatif option
# short of provision for switch
# NOTE: using  a Powershell's 'boolean' string value 
# cannot use Ruby boolean due to lack of conversion
# default['target_node']['powershell_noop'] = '$false'
default['target_node']['powershell_noop'] = false
