log "Setting local yum repository for java #{node['wrapper_yum']['install_flavor']} version #{node['wrapper_yum']['jdk_version']} #{node['wrapper_yum']['arch']}" do
  level :info
end
@baseurl = node['wrapper_yum']['baseurl']
@metadata_expire = node['wrapper_yum']['metadata_expire']

# TODO: need to add http://localhost:8080/artifactory/ext-release-local/jdk/jdk/7u71-linux/repodata/repomd.xml 
# https://github.com/chef-cookbooks/yum
include_recipe 'yum'
yum_repository 'hal_java' do
  description 'HAL repo'
  baseurl "http://localhost:8080/artifactory/ext-release-local/jdk/jdk/7u71-linux/"
  action :create
  enabled true
  gpgcheck false
  metadata_expire @metadata_expire 
  sslverify  true
end

log 'Finished configuring local yum repository.' do
  level :info
end


