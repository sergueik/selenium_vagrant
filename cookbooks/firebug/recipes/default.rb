log 'Preparing Firebug plugin' do
  level :info
end

# Define variables for attributes
use_default_version = false
account_username = node['vnc']['account_username'];
account_home = "/home/#{account_username}";
selenium_home = "#{account_home}/selenium"
selenium_version = node['firebug']['firebug']['version']
firebug_local_file = "firebug-#{node['firebug']['firebug']['version']}.xpi" 

# TODO: detect the proxy issue ?
remote_file "#{selenium_home}/#{firebug_local_file}" do
  source node['firebug']['firebug']['url']
  action :create_if_missing
  ignore_failure true
  owner account_username
end
# Extract and place the directory
bash 'extract_release_archive' do
  cwd ::File.dirname(selenium_home)
  code <<-EOH
     /usr/bin/wget -O "#{selenium_home}/#{firebug_local_file}" #{node['firebug']['firebug']['url']}
     chown #{account_username}:#{account_username} "#{selenium_home}/#{firebug_local_file}"
   EOH
   not_if { ::File.exists?("#{selenium_home}/#{firebug_local_file}") }
end

log 'Finished preparing Firebug plugin.' do
  level :info
end

