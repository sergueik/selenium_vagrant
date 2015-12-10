log "Installing  groovy #{node[:groovy][:version]} version" do
  level :info
end

include_recipe 'groovy'
log 'Finished configuring java.' do
  level :info
end


