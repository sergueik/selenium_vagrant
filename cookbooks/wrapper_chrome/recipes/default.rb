log "Installing chrome version #{node['chrome']['track']}" do
  level :info
end
include_recipe 'chrome'
# NOTE: chromedriver is handled by selenium-node cookbook
log 'Finished configuring chrome.' do
  level :info
end


