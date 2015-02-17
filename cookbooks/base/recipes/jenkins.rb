package 'jenkins' do
  action :install
end

service 'jenkins' do
  # replace with Upstart for 14.04
 puts node[:platform_version]
 if node[:platform_version].match( /14\./)
   provider Chef::Provider::Service::Upstart
   puts 'using upstart service provider for jenkins'
 else
   provider Chef::Provider::Service::Debian
   puts 'using debian service provider for jenkins '
 end
#  Chef::Exceptions::UnsupportedAction:
# #<Chef::Provider::Service::Init:0xb821d3c> does not support :enable

  action [:enable, :start]
  supports :status => true, :restart => true
end
