log "Installing custom purge scripts version #{node['chrome']['track']}" do
  level :info
end
# TODO: install java and maven to use maven command to purge stuff
# https://stackoverflow.com/questions/7408545/how-do-you-clear-apache-mavens-cache
# include_recipe 'java'

# Define variables for attributes
use_default_version = false
account_username = node['vnc']['account_username']
critical_size = node['vnc']['critical_size'].to_i
account_home = "/home/#{account_username}"
purge_script = 'purge.sh'

package 'Install unzip' do
  package_name 'unzip'
  action :install
  ignore_failure false
end
directory "#{account_home}/scripts" do
  owner account_username
  group account_username
  mode  00755
  recursive true
  action :create
end
# Create purge launcher script for debugging Selenium Node issues
template ("#{account_home}/scripts/#{purge_script}") do
  source 'purge.erb'
  variables(
    :critical_size => critical_size,
    # :hub_ip => node['selenium_node']['hub_ip'],
    )
  owner account_username
  group account_username
  mode 00755
end

bash 'run cleanup scripts' do
    code <<-EOH
pushd "#{account_home}/scripts"
# assume it would like to run from a specific directory
./#{purge_script}
    EOH
    only_if { ::File.exists?("#{account_home}/scripts/#{purge_script}") }
end

log 'Finished configuring Node.' do
  level :info
end


