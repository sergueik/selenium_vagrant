require 'chef-vault'

environment = node.chef_environment
vault_databag = "#{environment}-vault"
application_databag = "#{environment}_tomcat_app_config"
service_name = 'hal-giftsf-server'


if data_bag(vault_databag).include? 'seedvalue'
  seed = ChefVault::Item.load(vault_databag, 'seedvalue')
  seedvalue = seed['seedvalue']
else
  seedvalue = ''
end


if data_bag(vault_databag).include? 'dbweb-enc'
  dbweb = ChefVault::Item.load(vault_databag, 'dbweb-enc')
else
  dbweb = ChefVault::Item.load(vault_databag, 'dbweb')
end

if data_bag(vault_databag).include? 'dbdwh-enc'
  dbdwh = ChefVault::Item.load(vault_databag, 'dbdwh-enc')
else
  dbdwh = ChefVault::Item.load(vault_databag, 'dbdwh')
end

dataBagItem = data_bag_item(application_databag, service_name)
application = dataBagItem[environment]['application']
rpm_version = application['rpm_version']
user_account = application['user']
group_account = application['group']


log "seedvalue=#{seedvalue}" do
  level :info
end

log "dbweb=#{dbweb}" do
  level :info
end

log "dbdwh=#{dbdwh}" do
  level :info
end

log "user=#{user_account}" do
  level :info
end

log "group=#{group_account}" do
  level :info
end

log "rpm_version=#{rpm_version}" do
  level :info
end

yum_package service_name do
  version rpm_version
  allow_downgrade true
end

service service_name do
  supports :start => true, :stop => true, :restart => true, :condrestart => true, :status => true
  action :start
end

template "/etc/#{service_name}/setenv.sh" do
  source 'setenv.sh.erb'
  owner user_account
  group group_account
  mode 00644
  variables(
      :http_port => application['ports']['http'],
      :https_port => application['ports']['https'],
      :jmx_port => application['ports']['jmx'],
      :ajp_port => application['ports']['ajp'],
      :shutdown_port => application['ports']['shutdown'],
      :spring_profiles_active => application['spring_profiles_active'],
      :Xms => application['memory']['Xms'],
      :Xmx => application['memory']['Xmx'],
      :PermSize => application['memory']['PermSize'],
      :MaxPermSize => application['memory']['MaxPermSize'],
      :seedvalue => seedvalue
  )
  notifies :restart, "service[#{service_name}]"
end


