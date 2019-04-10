log "Installing vnc" do
  level :info
end

group 'vncuser' do
  append true
  gid    1014
  system true
  action :create
  notifies :create, 'user[vncuser]', :delayed
end

user 'vncuser' do
  username 'vncuser'
  comment  'A vnc selenium user'
  uid      1014
  group    'vncuser'
  # cannot determine group id for 'vncuser', does the group exist on this system
  home     '/home/vncuser'
  shell    '/bin/bash'
  password 'vncuser'
  system   true
  notifies :install, 'package[vnc-client]', :delayed
end

include_recipe 'vnc'
log 'Finished configuring vnc.' do
  level :info
end
