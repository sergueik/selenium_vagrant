package 'xvfb' do
  action :install
end
# TODO : the suggeston did not help:
# http://stackoverflow.com/questions/12644001/how-to-add-the-missing-randr-extension

# https://gist.github.com/dmitriy-kiriyenko/974392
template '/etc/init.d/Xvfb' do 
 variables(
     # uses attribute of different cookbook
     :display_port => node['selenium_node']['display_port'] 
 ) 
 source 'xvfb.erb'
 owner 'root'
 group 'root'
 mode 00755
end 

# start X window server
service 'Xvfb' do
  action :enable
  action :start
  supports :status => true, :restart => true
end
