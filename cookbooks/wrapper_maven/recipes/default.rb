log "Installing  maven version #{node['maven']['version']}" do
  level :info
end
# NOTE: a package 'maven' is available too. 
# Install maven - probably pretty old version
# On Ubuntu it installs version '3.0.5'
package 'maven' do
  action :install
end

include_recipe 'maven'
log 'Finished configuring maven.' do
  level :info
end


