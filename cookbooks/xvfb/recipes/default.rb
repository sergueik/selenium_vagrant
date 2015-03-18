log 'Installing XvbfServer' do
  level :info
end

# Define variables for attributes
# account_username = node['selenium']['account_username'];
 account_username = node['xvfb']['account_username'];

# Install xvfb
package 'xvfb' do
  action :install
end
# TODO : RANDR
# http://stackoverflow.com/questions/12644001/how-to-add-the-missing-randr-extension

# Enable the Xbfb server service
# https://gist.github.com/dmitriy-kiriyenko/974392
template '/etc/init.d/Xvfb' do 
 variables(
     :display_port => node['xvfb']['display_port'],
     :user_name => account_username
 ) 
 source 'xvfb.erb'
 owner 'root'
 group 'root'
 mode 00755
end 

# Start X window server
service 'Xvfb' do
  action [:enable, :start]
  supports :status => true, :restart => true
end

log 'Finished configuring Xvfb server.' do
  level :info
end
