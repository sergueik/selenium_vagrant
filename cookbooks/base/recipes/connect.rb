group 'connect' do
  gid 15000
  action :create
end

user 'connect' do
  supports :manage_home => true
  comment 'D-Deployer'
  uid 15000
  gid 15000
  home '/home/connect'
  shell '/bin/bash'
end

directory '/home/connect/.ssh' do
  owner 'connect'
  group 'conect'
  mode  00755
  action :create
end

cookbook_file '/home/connect/.ssh/authorized_keys' do
  source 'connect.pub'
  owner 'connect'
  group 'connect'
  action :create_if_missing
  mode 00600
end
