log "Installing vnc" do
  level :info
end
include_recipe 'vnc'
log 'Finished configuring vnc.' do
  level :info
end
