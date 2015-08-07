log 'Installing Selenium hub' do
  level :info
end

# Define variables for attributes
account_username = node['vnc']['account_username'];
account_home     = "/home/#{account_username}";
selenium_home = "#{account_home}/selenium"
account_home     = "/home/#{account_username}";
selenium_home = "#{account_home}/selenium"
selenium_version  = node['selenium']['selenium']['version']
standalone_script = 'run-hub.sh'
log4j_properties_file = 'hub.log4j.properties'
log4j_xml= 'log4j.xml'
logfile = 'hub.log'
logger = 'INFO'
jar_filename = 'selenium.jar'

%w{selenium_hub}.each do |init_script| 

  # Create selenium node service script configuratrion required for provider.
  file "/etc/init/#{init_script}.conf"  do
    owner 'root'
    group 'root'
    mode 00755 
    action :create_if_missing
    only_if node['platform_version'].to_i >= 14
  end
  # Create service init script for Selenium Hub
  template ("/etc/init.d/#{init_script}") do 
    source 'initscript.erb'
    variables(
      :user_name => account_username,
      :selenium_home => selenium_home,
      :log4j_properties_file =>log4j_properties_file ,
      :hub_port => node['selenium_node']['hub_port'],
      :jar_filename  => jar_filename 
    ) 
    owner 'root'
    group 'root'
    mode 00755
  end 
end

# Create Selenium folder
directory selenium_home do
  owner account_username
  group account_username
  mode  00755
  recursive true
  action :create
end

# Create standalone launcher script for debugging Selenium Hub
template ("#{selenium_home}/#{standalone_script}") do 
  source 'standalone.erb'
  variables(
    :log4j_properties_file =>log4j_properties_file ,
    :hub_port => node['selenium_node']['hub_port'],
    :jar_filename  => jar_filename 
    ) 
  owner account_username
  group account_username
  mode  00755
end 


# Install Selenium jar
remote_file "#{selenium_home}/#{jar_filename}" do
  source node['selenium']['selenium']['url']
  action :create_if_missing
  ignore_failure true
  # TODO: ensure specific version
  owner account_username
end

# Workaround Net::HTTPServerException 407 Forefront TMG Proxy issue 
bash 'extract_jar' do
  cwd ::File.dirname(selenium_home)
  code <<-EOH
     /usr/bin/wget -O "#{selenium_home}/#{jar_filename}" #{node['selenium']['selenium']['url']} 
    EOH
  not_if { ::File.exists?("#{selenium_home}/#{jar_filename}") }
end

# Start the Selenium Hub service 
%w{selenium_hub}.each do |service_name|
  service service_name do
    # NOTE: Init replace with Upstart for 14.04
    if node['platform_version'].to_i < 14 
      provider Chef::Provider::Service::Debian
    else
      provider Chef::Provider::Service::Upstart
    end
    action [:enable,:start]
    supports :status => true, :restart => true
    subscribes :reload, "/etc/init.d/#{service_name}", :immediately
  end
end

# Create log4j properties
template "#{selenium_home}/#{log4j_properties_file}" do
  source 'log4j_properties.erb'
  variables(
     :logger => logger,
     :logfile => logfile
  )
  owner account_username
  group account_username
  action :create_if_missing
  mode 00644
end

log 'Finished configuring Selenium Hub.' do
  level :info
end
