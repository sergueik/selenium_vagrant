log "Installing vnc" do
  level :info
end

# Create user & group
user 'vncuser' do
  # undefined method `supports' for Chef::Resource::User::LinuxUser
  # supports :manage_home => true
  manage_home true
  gid         'users'
  system      true
  comment     'vnc selenium user'
  password    'vncuser'
end

group 'vncuser' do
  action   :create
  members  ['vncuser']
  # optional
  notifies :install, 'package[vnc-client]', :delayed
end

include_recipe 'vnc'
log 'Finished configuring vnc.' do
  level :info
end
