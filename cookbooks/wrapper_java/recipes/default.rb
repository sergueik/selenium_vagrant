log "Installing  java #{node['java']['install_flavor']} version #{node['java']['jdk_version']} #{node['java']['arch']}" do


  level :info
end

include_recipe 'java'
log 'Finished configuring java.' do
  level :info
end


