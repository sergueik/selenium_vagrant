log 'configuring hosts' do
  level :info
end

append_rest_to_first = node['wrapper_hostsfile']['append_rest_to_first']
sut_hosts = node['wrapper_hostsfile']['sut_hosts'] 
loopback_hostnames = node['wrapper_hostsfile']['loopback_hostnames'] 

if append_rest_to_first
  hostsfile_entry '127.0.0.1' do
    hostname  loopback_hostnames[0]
    aliases loopback_hostnames.drop(1) unless loopback_hostnames.count == 1 
    action    :append
  end
else
  loopback_hostnames.each do |loopback_hostname|
    hostsfile_entry '127.0.0.1' do
      hostname  loopback_hostname
      action    :append
    end
   end
end
sut_hosts.each do |sut_ip,sut_hostnames| 
  if sut_hostnames.is_a? Array
    hostsfile_entry sut_ip  do
      hostname sut_hostnames[0]
      aliases sut_hostnames.drop(1) unless sut_hostnames.count == 1 
      unique true
      action :create_if_missing
    end
  else 
    hostsfile_entry sut_ip  do
      hostname sut_hostnames
      unique true
      action :create_if_missing
    end
  end 
end

log 'Finished configuring hostfiles.' do
  level :info
end




