%w(firefox linuxvnc xvfb).each do |package_name| 
  package package_name do
    action :install
  end
end
# TODO : the suggeston did not help:
# http://stackoverflow.com/questions/12644001/how-to-add-the-missing-randr-extension

# TODO - generate profile directories

puts  \
node['selenium']['display_driver']['install_flavor']




# http://www.abdevelopment.ca/blog/start-vnc-server-ubuntu-boot
cookbook_file '/etc/init.d/vncserver' do 
 source 'vncserver'
 owner 'root'
 group 'root'
 mode 00755
 Chef::Log.info('generate init script for linuxvnc servr')
end 

# https://gist.github.com/dmitriy-kiriyenko/974392
template '/etc/init.d/Xvfb' do 
 variables(
     :display_port => node['selenium']['display_port'] 
 ) 
 source 'xvfb.erb'
 owner 'root'
 group 'root'
 mode 00755
 Chef::Log.info('generate init script for xvfb servr')
end 

# TODO: create a user to run Vnc (not really necessary with Xvfb)
# TODO: create a .vnc directory for that user

# https://github.com/esycat/selenium-grid-init
%w{selenium_hub selenium_node}.each do |init_script| 
  template ("/etc/init.d/#{init_script}") do 
    source"#{init_script}.erb"
    variables(
	:hub_port => node['selenium']['hub_port'], 
	:node_port => node['selenium']['node_port'],
	:node => node['selenium']['node'] ,
	:hub_ip => node['selenium']['hub_ip'], 
	:display_port => node['selenium']['display_port'] 
    ) 
    owner 'root'
    group 'root'
    mode 00755
    Chef::Log.info('generate #{init_script}')
  end 
end

directory '/root/selenium' do
  owner 'root'
  group 'root'
  mode  00755
  action :create
end

# Recipe Compile Error
remote_file "#{Chef::Config[:file_cache_path]}/selenium.jar" do
  source "#{node['selenium']['selenium']['url']}"
  action :create_if_missing
# NOTE version !
 Chef::Log.info('downloaded selenium jar '  + node['selenium']['selenium']['url'] + ' into: ' + Chef::Config[:file_cache_path])
end

remote_file '/root/selenium/selenium.jar' do
  source "#{node['selenium']['selenium']['url']}"
  action :create_if_missing
 # NOTE version !
  Chef::Log.info('downloaded selenium jar '  + node['selenium']['selenium']['url'] + ' into: ' + '/root/selenium/selenium.jar' )
  owner 'root'
  action :create
end

template '/root/selenium/node.json' do
  source 'node.json.erb'
  variables(
     # NOTE: do not use :platform
     :my_platform => node['selenium']['my_platform']
  )
  owner 'root'
  group 'root'
  mode 00644
  Chef::Log.info('configure node')
end
 
# start X window server
%w{vncserver Xvfb}.each do |service_name|
  service service_name do
    # NOTE: Init replace with Upstart for 14.04
    unless node[:platform_version].match( /14\./).nil?
      provider Chef::Provider::Service::Upstart
    else
      provider Chef::Provider::Service::Debian
    end
    action [:enable, :start]
    supports :status => true, :restart => true
    Chef::Log.info("started #{service_name}")
  end
end

# http://www.apache.org/dyn/closer.cgi/logging/log4j/1.2.17/log4j-1.2.17.tar.gz
remote_file "#{Chef::Config[:file_cache_path]}/log4j.tar.gz" do
  source "#{node['selenium']['log4j']['url']}"
# NOTE version !
 Chef::Log.info('downloaded selenium jar into: ' + Chef::Config[:file_cache_path])
end

execute 'extract_log4j' do
  command 'tar xzvf ' + "#{Chef::Config[:file_cache_path]}/log4j.tar.gz" 
  cwd '/root/selenium'
  not_if { File.exists?('log4j-1.2.17.jar') }
end

remote_file "Copy_log4j" do 
  path "/root/selenium/log4j-1.2.17.jar" 
  source "file:///root/selenium/apache-log4j-1.2.17/log4j-1.2.17.jar"
  owner 'root'
  group 'root'
  mode 0755
  not_if { File.exists?('log4j-1.2.17.jar') }
end

# start Selenium server and client
%w{selenium_hub selenium_node}.each do |service_name|
  service service_name do
    unless node[:platform_version].match( /14\./).nil?
      provider Chef::Provider::Service::Upstart
    else
      provider Chef::Provider::Service::Debian
    end
    action [:enable, :start]
    supports :status => true, :restart => true
    # subscribes :reload, "/etc/init.d/#{service_name}", :immediately
    Chef::Log.info("started #{service_name}")
  end
end
# TODO: optionally start phantomJS



# ssh -o StrictHostKeyChecking=no username@hostname.com
