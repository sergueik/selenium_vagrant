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
# enable as needed
default['target_node']['debug'] = false
