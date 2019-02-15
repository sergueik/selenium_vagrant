default['target_node']['script_version'] = '0.3'


# @basedir is the parent dir of .m2 e.g. for prod: '/opt/jenkins'
default['target_node']['basedir'] = '/home/vagrant' 
# the high disk usage of @disk would trigger the purge script
default['target_node']['disk'] = '/dev/sda1' 
# Bash script 'purge.sh' is created under account_username home directory 
default['target_node']['account_username'] = 'vagrant' 
# the high disk usage over @high_percent is considered high
default['target_node']['high_percent'] = 3
# when do_purge is set to true, the bash script `purge.sh` is run in every
# chef run, otherwise it will examine the df output for filesystem mounted to @mount_dir
default['target_node']['do_purge'] = true
default['target_node']['mount_dir'] = 'vagrant'
default['target_node']['password'] = 'password'


