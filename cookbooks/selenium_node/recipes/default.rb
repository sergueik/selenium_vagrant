%w(firefox).each do |package_name| 
  package package_name do
    action :install
  end
end
# TODO : the suggeston did not help:
# http://stackoverflow.com/questions/12644001/how-to-add-the-missing-randr-extension

# TODO - generate profile directories

# https://github.com/esycat/selenium-grid-init
%w{selenium_node}.each do |init_script| 
  template ("/etc/init.d/#{init_script}") do 
    source"#{init_script}.erb"
    variables(
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

directory '/home/vncuser/selenium' do
  owner 'vncuser'
  group 'vncuser'
  mode  00755
  action :create
end

remote_file '/home/vncuser/selenium/selenium.jar' do
  source "#{node['selenium_node']['selenium']['url']}"
  action :create_if_missing
  # NOTE version !
  owner 'vncuser'
end

template '/home/vncuser/selenium/node.json' do
  source 'node.json.erb'
  variables(
     # NOTE: do not use :platform
     :my_platform => node['selenium_node']['my_platform']
  )
  owner 'vncuser'
  group 'vncuser'
  mode 00644
end
 
# start Selenium server and client
%w{selenium_node}.each do |service_name|
  service service_name do
    unless node[:platform_version].match( /14\./).nil?
      provider Chef::Provider::Service::Upstart
    else
      provider Chef::Provider::Service::Debian
    end
    action :enable
    action :start
    supports :status => true, :restart => true
    # subscribes :reload, "/etc/init.d/#{service_name}", :immediately
  end
end
