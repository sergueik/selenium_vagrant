log 'Installing Selenium node' do
  level :info
end

# Define variables for attributes
account_username = node['vnc']['account_username'];
account_home     = "/home/#{account_username}";

# Install Firefox
package 'Install Firefox' do
  package_name 'firefox'
  action :install
end

# TODO - generate profile directories

# Create selenium node service script.
%w{selenium_node}.each do |init_script| 
  template ("/etc/init.d/#{init_script}") do 
    source "#{init_script}.erb"
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

directory "#{account_home}/selenium" do
  owner account_username
  group account_username
  mode  00755
  recursive true
  action :create
end

remote_file "#{account_home}/selenium/selenium.jar" do
  source node['selenium_node']['selenium']['url']
  action :create_if_missing
  # NOTE version !
  owner account_username
end

template "#{account_home}/selenium/node.json" do
  source 'node.json.erb'
  variables(
     # NOTE: do not use :platform
     :my_platform => node['selenium_node']['my_platform']
  )
  owner account_username
  group account_username
  mode 00644
end
 
# Start Selenium server and client
%w{selenium_node}.each do |service_name|
  service service_name do
    unless node[:platform_version].match( /14\./).nil?
      provider Chef::Provider::Service::Upstart
    else
      provider Chef::Provider::Service::Debian
    end
    action [:enable, :start]
    supports :status => true, :restart => true
    subscribes :reload, "/etc/init.d/#{service_name}", :immediately
  end
end

log 'Finished configuring Selenium node.' do
  level :info
end
