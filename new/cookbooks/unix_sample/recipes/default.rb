log "Installing custom purge scripts version #{node['purge']['track']}" do
  level :info
end
# TODO: install java and maven to use maven command to purge stuff
# https://stackoverflow.com/questions/7408545/how-do-you-clear-apache-mavens-cache
# include_recipe 'java'

# Define variables for attributes
use_default_version = false
account_username = node['purge']['account_username']
critical_percent = node['purge']['critical_percent'].to_i
critical_percent = 72 
mount = node['purge']['mount']
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
# Create purge script
template ("#{account_home}/scripts/#{purge_script}") do
  source 'purge.erb'
  variables(
    :critical_percent => critical_percent,
    :mount            => mount,
    :ipaddress        => node['ipaddress'],
    )
  owner account_username
  group account_username
  notifies :run, 'bash[run purge script]', :delayed
  mode 00755
end

bash 'run purge script' do
    code <<-EOF
pushd "#{account_home}/scripts"
# assume it would like to run from a specific directory
./#{purge_script}
    EOF
    ignore_failure true
    only_if { ::File.exists?("#{account_home}/scripts/#{purge_script}") }
end

log 'Finished configuring Node.' do
  level :info
end


