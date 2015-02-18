# default jdk attributes
default['java']['install_flavor'] = "openjdk"
default['java']['jdk_version'] = '6'
default['java']['arch'] = kernel['machine'] =~ /x86_64/ ? "x86_64" : "i586"
