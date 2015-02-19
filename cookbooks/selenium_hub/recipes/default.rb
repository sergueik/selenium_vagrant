log 'Installing Selenium hub' do
  level :info
end

# Define variables for attributes
account_username = node['vnc']['account_username'];

# Create a selenium hub service script.
# https://github.com/esycat/selenium-grid-init
%w{selenium_hub}.each do |init_script| 
  template ("/etc/init.d/#{init_script}") do 
    source"#{init_script}.erb"
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
directory '/home/vncuser/selenium' do
  owner account_username 
  group account_username 
  mode  00755
  recursive true
  action :create
end

# Install selenium jar
remote_file '/home/vncuser/selenium/selenium.jar' do
  source node['selenium_node']['selenium']['url']
  action :create_if_missing
 # TODO version !
  owner account_username 
end

# http://www.apache.org/dyn/closer.cgi/logging/log4j/1.2.17/log4j-1.2.17.tar.gz
remote_file "#{Chef::Config[:file_cache_path]}/log4j.tar.gz" do
  source node['selenium_node']['log4j']['url']
# NOTE version !
end

execute 'extract_log4j' do
  command 'tar xzvf ' + "#{Chef::Config[:file_cache_path]}/log4j.tar.gz" 
  cwd '/home/vncuser/selenium'
  not_if { File.exists?('log4j-1.2.17.jar') }
end

remote_file "Copy_log4j" do 
  path "/home/vncuser/selenium/log4j-1.2.17.jar" 
  source "file:///home/vncuser/selenium/apache-log4j-1.2.17/log4j-1.2.17.jar"
  owner account_username
  group account_username 
  mode 00755
  not_if { File.exists?('log4j-1.2.17.jar') }
end

# start the service 
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

log 'Finished configuring Selenium hub.' do
  level :info
end
