# default jdk attributes
default['java']['install_flavor'] = 'oracle'
default['java']['jdk_version'] = '7'
default['java']['arch'] = kernel['machine'] =~ /x86_64/ ? 'x86_64' : 'i586'
default['java']['oracle']['accept_oracle_download_terms'] = true
