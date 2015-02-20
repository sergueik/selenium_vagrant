log 'Installing Selenium hub' do
  level :info
end

# Define variables for attributes
account_username = node['vnc']['account_username'];
account_home     = "/home/#{account_username}";
selenium_home = "#{account_home}/selenium"
log4j_properties_file = 'hub.log4j.properties'

# Create selenium hub service script.
%w{selenium_hub}.each do |init_script| 
  template ("/etc/init.d/#{init_script}") do 
    source 'initscript.erb'
    variables(
        :user_name => account_username,
	:hub_port => node['selenium_node']['hub_port'], 
	:node_port => node['selenium_node']['node_port'],
	:node => node['selenium_node']['node'] ,
	:hub_ip => node['selenium_node']['hub_ip'], 
	:display_port => node['selenium_node']['display_port'] 
    ) 
    owner 'root'
    group 'root'
    mode 00755
  end 
end

# Create selenium folder
directory "#{account_home}/selenium" do
  owner account_username 
  group account_username 
  mode  00755
  recursive true
  action :create
end

# Install selenium jar
remote_file "#{account_home}/selenium/selenium.jar" do
  source node['selenium_node']['selenium']['url']
  action :create_if_missing
 # TODO version !
  owner account_username 
end

# Create log4j properties
template  "#{selenium_home}/#{log4j_properties_file}" do
  source 'log4j.properties.erb'
      variables(
        :logger =>  node['selenium_hub']['logger'] || 'INFO',
	:logfile => node['selenium_hub']['logfile'] || 'hub.log'
    ) 
  user "#{account_username}"
  user "#{account_username}"
  action :create_if_missing
  mode 00600
end

# Start the service 
%w{selenium_hub}.each do |service_name|
  service service_name do
    # NOTE: Init replace with Upstart for 14.04
    unless node[:platform_version].match( /14\./).nil?
      provider Chef::Provider::Service::Upstart
    else
      provider Chef::Provider::Service::Debian
    end
    action [:enable,:start]
    supports :status => true, :restart => true
    # ?
    subscribes :reload, "/etc/init.d/#{service_name}", :immediately
  end
end

# http://www.devopsnotes.com/2012/02/how-to-write-good-chef-cookbook.html

log 'Finished configuring Selenium hub.' do
  level :info
end