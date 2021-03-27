# desired jdk attributes
default['wrapper_yum']['install_flavor'] = 'oracle'
default['wrapper_yum']['jdk_version'] = '7'
default['wrapper_yum']['arch'] = kernel['machine'] =~ /x86_64/ ? 'x86_64' : 'i586'
# in house yum repo
default['wrapper_yum']['baseurl'] = "http://localhost:8080/artifactory/ext-release-local/jdk/jdk/7u71-linux/"
default['wrapper_yum']['metadata_expire'] = 120
