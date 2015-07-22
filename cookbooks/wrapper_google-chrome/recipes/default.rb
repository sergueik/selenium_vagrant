log "Installing googlel-chrome version #{node['google-chrome']['track']}" do
  level :info
end
include_recipe 'google-chrome'
# NOTE : chromedriver is handled by selenium-node cookbook
# SEE ALSO: https://github.com/danggrianto/selenium-vm
# for handling missing name attribute of google-chrome cookbook
log 'Finished configuring google-chrome.' do
  level :info
end


