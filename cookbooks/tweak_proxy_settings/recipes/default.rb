
log 'Clear proxy settings' do
  level :info
end

config_files = %w|
  /etc/apt/apt.conf.d/01proxy
  /etc/environment
  /etc/profile.d/proxy.sh
|
# TODO  /etc/resolv.conf

config_files.each  do |config_file|

# Net::HTTPServerException 407 Forefront TMG Proxy issue 
bash 'comment_proxy' do
  cwd ::File.dirname(config_file)
  code <<-EOH

CONFIG="#{config_file}"
echo sed -i.BAK 's/^\(HTTPS*_PROXY=\)/# \1/i' ${CONFIG}
sed -i.BAK 's/^\(HTTPS*_PROXY=\)/# \1/i' ${CONFIG}

    EOH
  only_if { ::File.exists?( config_file  ) }
end

end 
log 'Finished clearing proxy settings.' do
  level :info
end


