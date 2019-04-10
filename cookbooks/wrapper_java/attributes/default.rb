# default jdk attributes
default['java']['install_flavor'] = 'openjdk'
default['java']['jdk_version'] = '7'
# patching the undefined 'kernel' method
kernel = { 'machine'  => 'x86_64' }
default['java']['arch'] = kernel['machine'] =~ /x86_64/ ? 'x86_64' : 'i586'
default['java']['oracle']['accept_oracle_download_terms'] = true
