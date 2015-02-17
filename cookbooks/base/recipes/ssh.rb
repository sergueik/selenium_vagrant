package 'openssh-server' do
  action :install
end

cookbook_file '/etc/ssh/ssh_config' do
  source 'ssh_config'
  owner 'root'
  group 'root'
  mode '0640'
  notifies :reload, 'service[ssh]'
end

service 'ssh' do
  # replace with Upstart for 14.04
 puts node[:platform_version]
 if node[:platform_version].match?( /14\./)
   provider Chef::Provider::Service::Upstart
   puts 'using upstart service provider'
 else
   provider Chef::Provider::Service::Debian
   puts 'using debian service provider:'
 end
#  Chef::Exceptions::UnsupportedAction:
# #<Chef::Provider::Service::Init:0xb821d3c> does not support :enable

  action [:enable, :start]
  supports :status => true, :restart => true
end
# use http://serverfault.com/questions/132970/can-i-automatically-add-a-new-host-to-known-hosts
# ssh -o StrictHostKeyChecking=no username@hostname.com
