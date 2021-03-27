log "Installing chrome version #{node['chrome']['track']}" do
  level :info
end
include_recipe 'chrome'
# NOTE: chromedriver is handled by selenium-node cookbook
# https://supermarket.chef.io/cookbooks/google-chrome/download
log 'Finished configuring chrome.' do
  level :info
end


