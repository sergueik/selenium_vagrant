log 'Installing Selenium node' do
  level :info
end

# Define variables for attributes
use_default_version = false
account_username = node['vnc']['account_username'];
account_home = "/home/#{account_username}";
selenium_home = "#{account_home}/selenium"
selenium_version = node['selenium']['selenium']['version']
standalone_script = 'run-node.sh'

# TODO - choose which X server to install
# display_port = node['vnc']['display_port'] 
display_port = node['xvfb']['display_port']

jar_filename = 'selenium.jar'
log4j_properties_file = 'node.log4j.properties'
logfile = 'node.log'
logger = 'INFO'
node_host = '127.0.0.1'
firefox_install_archive = "firefox-#{node['selenium']['firefox']['version']}.tar.bz2" 
chrome_driver_install_archive = "chromedriver_linux-#{node['selenium']['chrome_driver']['version']}-#{node['selenium']['chrome_driver']['arch']}.zip"
# Install ChromeDriver
remote_file "#{account_home}/selenium/#{chrome_driver_install_archive}" do
  source node['selenium']['chrome_driver']['url']
  action :create_if_missing
  ignore_failure true
  owner account_username
end
package 'Install unzip' do
  package_name 'unzip'
  action :install
  ignore_failure false
end

# http://askubuntu.com/questions/510056/how-to-install-google-chrome-on-ubuntu-14-04
bash 'set prerequisites for install chrome as package' do
    code <<-EOH

# Add Key:
/usr/bin/wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - 
# Set repository:
echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list
# Update apt-get db
apt-get update 

    EOH
    not_if { ::File.exists?('/etc/apt/sources.list.d/google.list') }
  end

# Install Chrome
package 'Install Chrome browser' do
  package_name 'google-chrome-stable'
  action :install
  ignore_failure false
  # NOTE: will be installed in /opt/google/chrome by default 
end

# Install Firefox
if use_default_version
  package 'Install Firefox  browser' do
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
  remote_file "#{account_home}/selenium/#{firefox_install_archive}" do
    source node['selenium']['firefox']['url']
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
     /usr/bin/wget -O "#{selenium_home}/#{firefox_install_archive}" "#{node['selenium']['firefox']['url']}"
     pushd #{selenium_home}
     /bin/tar xjvf "#{selenium_home}/#{firefox_install_archive}" -C #{selenium_home}
     chown -R #{account_username}:#{account_username} .

    EOH
    not_if { ::File.exists?("#{selenium_home}/firefox/firefox-bin") }
  end

end

# TODO - generate Firefox Profile directories
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


# currently only works with precise and not with trusty
%w{selenium_node}.each do |init_script| 

  # Create Selenium Node service script configuratrion required for provider.
  if node[:platform_version].to_i >= 14   
    file "/etc/init/#{init_script}.conf"  do
      owner 'root'
      group 'root'
      mode 00755
      action :create_if_missing
    end
  end

  # Create service init script for Selenium Node
  template ("/etc/init.d/#{init_script}") do 
    source 'initscript.erb'
    variables(
      :user_name => account_username,
      :selenium_home => selenium_home,
      :log4j_properties_file =>log4j_properties_file ,
      :hub_ip => node['selenium_node']['hub_ip'], 
      :hub_port => node['selenium_node']['hub_port'], 
      :node_host => node_host,
      :node_port => node['selenium_node']['node_port'],
      :display_port => display_port, 
      :jar_filename  => jar_filename 
    ) 
    owner account_username
    group account_username
    mode 00755
  end 
end

# Create Selenium Node folder
directory selenium_home do
  owner account_username
  group account_username
  mode  00755
  recursive true
  action :create
end

# TODO: apply proxy issue workaround

# TODO  encode firefox_binary path in the launcher scripts 
# TODO  encode chrome_driver_binary path in the launcher scripts 
# -Dwebdriver.chrome.driver="..."

# Create standalone launcher script for debugging Selenium Node issues
template ("#{selenium_home}/#{standalone_script}") do 
  source 'standalone.erb'
  variables(
    :user_name => account_username,
    :selenium_home => selenium_home,
    :log4j_properties_file =>log4j_properties_file ,
    :hub_ip => node['selenium_node']['hub_ip'], 
    :hub_port => node['selenium_node']['hub_port'], 
    :node_host => node_host,
    :node_port => node['selenium_node']['node_port'],
    :display_port => display_port,
    :jar_filename  => jar_filename 
    ) 
  owner account_username
  group account_username
  mode 00755
end 

remote_file "#{selenium_home}/#{jar_filename}" do
  source node['selenium']['selenium']['url']
  action :create_if_missing
  ignore_failure true
  # NOTE version !
  owner account_username
end

# Create Selenium Node configuration file

template "#{selenium_home}/node.json" do
  source 'node.json.erb'
  variables(
    # NOTE: do not use :platform
    :my_platform => node['selenium_node']['my_platform'],
    :node_host => node_host
  )
  owner account_username
  group account_username
  mode 00644
end
 
# Start Selenium Node service
%w{selenium_node}.each do |service_name|
  service service_name do
    unless node[:platform_version].to_i < 14 
      provider Chef::Provider::Service::Upstart
    else
      provider Chef::Provider::Service::Debian
    end
    action [:enable,:start]
    supports :status => true, :restart => true
    subscribes :reload, "/etc/init.d/#{service_name}", :immediately
  end
end

log 'Finished configuring Selenium Node.' do
  level :info
end

