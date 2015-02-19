log 'Installing Selenium hub' do
  level :info
end

# Define variables for attributes
account_username = node['vnc']['account_username'];
account_home     = "/home/#{account_username}";
jar_filename = 'log4j-1.2.17.jar'
tarball_filename= 'log4j.tar.gz'
tarball_filepath = "#{Chef::Config['file_cache_path']}/#{tarball_filename}"
selenium_home = "#{account_home}/selenium"


# Create selenium hub service script.
%w{selenium_hub}.each do |init_script| 
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

# Download tarball
remote_file tarball_filepath do
  source node['selenium_node']['log4j']['url']
  owner 'root'
  group 'root'
  mode 00644
end

# Extract and place the jar 
bash 'extract_jar' do
  cwd ::File.dirname(selenium_home)
  code <<-EOH
    
    tar xzf #{tarball_filepath} -C #{selenium_home}
    pushd #{selenium_home}
    mv */#{jar_filename} .
    chown #{account_username}:#{account_username} #{jar_filename}

    EOH
  not_if { ::File.exists?("#{selenium_home}/#{jar_filename}") }
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
