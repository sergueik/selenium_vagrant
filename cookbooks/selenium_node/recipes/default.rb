log 'Installing Selenium node' do
  level :info
end

# Define variables for attributes
use_default_version = false
account_username = node['vnc']['account_username'];
account_home     = "/home/#{account_username}";
selenium_home = "#{account_home}/selenium"
selenium_version  = node['selenium_node']['selenium']['version']
standalone_script = 'run-node.sh'
display_port = node['selenium_node']['display_port'] 
display_port = node['xvfb']['display_port']
log4j_properties_file = 'node.log4j.properties'
logfile = 'node.log'
logger = 'INFO'

# Install Firefox
if use_default_version
  package 'Install Firefox' do
    package_name 'firefox'
    action :install
    ignore_failure false
  end
else
  # Ununstall Firefox
  package 'Install Firefox' do
    package_name 'firefox'
    action [:remove,:purge]
    ignore_failure true
  end
  directory "#{account_home}/selenium/firefox" do
    owner account_username
    group account_username
    mode  00755
    recursive true
    action :create
  end
  remote_file "#{account_home}/selenium/firefox-35.0.1.tar.bz2" do
    source node['selenium_node']['firefox']['url']
    action :create_if_missing
    #  will fail with, failure will be ignored 
    #  ==> default: Net::HTTPServerException
    #  ==> default: ------------------------
    #  ==> default: 407 "Proxy Authentication Required ( Forefront TMG requires authorization to fulfill the request. Access to the Web Proxy filter is denied.  )"
    ignore_failure true
    owner account_username
  end
  
  # Extract and place the directory
  bash 'extract_release_archive' do
    cwd ::File.dirname(selenium_home)
    code <<-EOH
     /usr/bin/wget -O "#{selenium_home}/firefox-35.0.1.tar.bz2" "#{node['selenium_node']['firefox']['url']}"
     pushd #{selenium_home}
     /bin/tar xjvf "#{selenium_home}/firefox-35.0.1.tar.bz2" -C #{selenium_home}
     chown -R #{account_username}:#{account_username} .

    EOH
    not_if { ::File.exists?("#{selenium_home}/firefox/firefox-bin") }
  end

end
# TODO - generate profile directories

# Create selenium node service script.
%w{selenium_node}.each do |init_script| 
  template ("/etc/init.d/#{init_script}") do 
    source 'initscript.erb'
    variables(
        :user_name => account_username,
	:selenium_home => selenium_home,
        :log4j_properties_file =>log4j_properties_file ,
	:hub_port => node['selenium_node']['hub_port'], 
	:node_port => node['selenium_node']['node_port'],
	:node => node['selenium_node']['node'] ,
	:hub_ip => node['selenium_node']['hub_ip'], 
	:display_port => display_port, 
    ) 
    owner account_username
    group account_username
    mode 00755
  end 
end

# Create selenium node standalone launcher script.
  template ("#{selenium_home}/#{standalone_script}") do 
    source 'standalone_sh.erb'
    variables(
        :user_name => account_username,
	:selenium_home => selenium_home,
        :log4j_properties_file =>log4j_properties_file ,
	:hub_port => node['selenium_node']['hub_port'], 
	:node_port => node['selenium_node']['node_port'],
	:node => node['selenium_node']['node'] ,
	:hub_ip => node['selenium_node']['hub_ip'], 
	:display_port => display_port,
    ) 
    owner 'root'
    group 'root'
    mode 00755
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
    action [:enable,:start]
    supports :status => true, :restart => true
    subscribes :reload, "/etc/init.d/#{service_name}", :immediately
  end
end

# Create log4j properties
template "#{selenium_home}/#{log4j_properties_file}" do
  source 'log4j_properties.erb'
  variables(
     # NOTE: do not use :platform
     :logger => logger,
     :logfile => logfile
  )
  owner account_username
  group account_username
  action :create_if_missing
  mode 00600
end

log 'Finished configuring Selenium node.' do
  level :info
end

