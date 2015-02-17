%w{vim ntp xmlstarlet build-essential}.each do |pkg|
  package pkg do
    Chef::Log.debug("installing #{pkg}")
    action :install
  end
end

execute 'yum' do
# TODO - capture the output of the command 
# http://stackoverflow.com/questions/16309808/how-can-i-put-the-output-of-a-chef-execute-resource-into-a-variable
command <<-EEE
 apt-get check
  EEE

end

