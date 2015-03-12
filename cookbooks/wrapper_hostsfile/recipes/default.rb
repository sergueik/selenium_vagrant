log 'configuring hosts' do
  level :info
end

append_rest_to_first = false
sut_hosts = {
# TODO: handle aliases 
 '172.26.5.51' =>   'www.carnival.com',
 '172.26.5.51' =>   'origin-www.carnival.com',
 '172.26.5.56' =>   'www.carnival.co.uk'
}

loopback_hostnames = %w/
    metrics.carnival.com
    smetrics.carnival.com
    metrics.carnival.co.uk
    smetrics.carnival.co.uk
    static.ak.facebook.com
    s-static.ak.facebook.com
    ad.doubleclick.net
    ad.yieldmanager.com
    pc1.yumenetworks.com
    fbstatic-a.akamaihd.net
    ad.amgdgt.com
  /
if append_rest_to_first
  hostsfile_entry '127.0.0.1' do
    hostname  loopback_hostnames[0]
    aliases   loopback_hostnames.drop(1) unless loopback_hostnames.count == 1 
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
sut_hosts.each do |sut_ip,sut_hostname| 
  hostsfile_entry sut_ip  do
  hostname sut_hostname
  unique true
  action :create_if_missing
  end 
end
log 'Finished configuring hostfiles.' do
  level :info
end




