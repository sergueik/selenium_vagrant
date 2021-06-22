require 'chef-vault'

environment = node.chef_environment
vault_databag = "#{environment}-vault"
application_databag = "#{environment}_tomcat_app_config"
service_name = 'company-media-server'
service_conf_name =  "/etc/company-chip-server/chip.conf"
server_conf_template = 'chip.conf.erb'
application_site =  'sitename'

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

mainframe = ChefVault::Item.load(vault_databag, 'mainframe')
dataBagItem = data_bag_item(application_databag, service_name)
application = dataBagItem[environment]['application']
rpm_version = application['rpm_version']
user_account = application['user']
group_account = application['group']

chef_gem 'chef-vault' do 
action :install
end


info = <<-INFO_END

seedvalue = #{seedvalue}
dbweb = #{dbweb}
dbdwh = #{dbdwh}
user = #{user_account}
group = #{group_account}
rpm_version = #{rpm_version}

INFO_END

log info do
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
  Chef::Log.info("written /etc/#{service_name}/setenv.sh")
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
  action :create
  notifies :restart, "service[#{service_name}]"
end


template  service_conf_name  do
  source server_conf_template
  owner user_account
  group group_account
  mode 00644
  variables(
# skip while mock up  is not ready 
      :dbweb_username => dbweb['dbweb_username'],
      :dbweb_password => dbweb['dbweb_password'],
      :dbweb_url => application['dbweb']['url'],
      :dbweb_driverClassName => application['dbweb']['driverClassName'],
      :dbdwh_username => dbdwh['dbdwh_username'],
      :dbdwh_password => dbdwh['dbdwh_password'],
      :dbdwh_url => application['dbdwh']['url'],
      :dbdwh_driverClassName => application['dbdwh']['driverClassName'],
      :mainframe_company_username => mainframe['company_username'],
      :mainframe_company_password => mainframe['company_password'],
      :mainframe_company_url => application['mainframe']['company']['url'],
      :sbn_company_username => mainframe['sbn_username'],
      :sbn_company_password => mainframe['sbn_password'],
      :sbn_company_url => application['mainframe']['sbn']['url'],
      :mainframe_load_cabin_metadata => application['mainframe']['load_cabin_metadata'],
      :mainframe_cabin_metadata_location => application['mainframe']['cabin_metadata_location'],
      :cms_url => application['cms']['url']
  )
  notifies :restart, "service[#{service_name}]"
end

template "/etc/nginx/sites-available/#{application_site}" do
  source 'nginx_server_block.erb'
  owner user_account 
  group group_account 
  mode 00644
  variables(
    :host_config => application['host_config']
  )
  notifies :reload, "service[nginx]"
end

service 'nginx' do
  supports :start => true, :stop => true, :restart => true, :condrestart => true, :'try-restart' => true, :'force-reload' => true, :upgrade => true, :reload => true, :status => true, :configtest => true
  action :start
end
