log "Installing gradle version #{node[:gradle][:version]}" do
  level :info
end

# On Ubuntu apt installs same version '1.5' of package 'gradle' as chef recipe
package 'gradle' do
  action :install
end

# NOTE: ignoring possible collsion.
include_recipe 'gradle'
log 'Finished configuring gradle.' do
  level :info
end


