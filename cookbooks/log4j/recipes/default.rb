log 'Installing log4j' do
  level :info
end

# Define variables for attributes
account_username = node['vnc']['account_username'];
account_home     = "/home/#{account_username}";
jar_filename = 'log4j-1.2.17.jar'
tarball_filename= 'log4j.tar.gz'
tarball_filepath = "#{Chef::Config['file_cache_path']}/#{tarball_filename}"
selenium_home = "#{account_home}/selenium"
log4j_properties_file = 'hub.log4j.properties'


# Create selenium folder
directory selenium_home  do
  owner account_username 
  group account_username 
  mode  00755
  recursive true
  action :create
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

# http://www.devopsnotes.com/2012/02/how-to-write-good-chef-cookbook.html

log 'Finished installing log4j.' do
  level :info
end