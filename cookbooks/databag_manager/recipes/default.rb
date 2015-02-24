require 'chef-vault'

environment = node.chef_environment
if data_bag("#{environment}-vault").include? 'seedvalue'
  seed = ChefVault::Item.load("#{environment}-vault", "seedvalue")
  seedvalue = "#{seed['seedvalue']}"
else
  seedvalue = ""
end


if data_bag("#{environment}-vault").include? 'dbweb-enc'
  dbweb = ChefVault::Item.load("#{environment}-vault", "dbweb-enc")
else
  dbweb = ChefVault::Item.load("#{environment}-vault", "dbweb")
end

if data_bag("#{environment}-vault").include? 'dbdwh-enc'
  dbdwh = ChefVault::Item.load("#{environment}-vault", "dbdwh-enc")
else
  dbdwh = ChefVault::Item.load("#{environment}-vault", "dbdwh")
end

databag = "#{environment}_tomcat_app_config"
dataBagItem = data_bag_item( "#{databag}", 'hal-giftsf-server')
application = dataBagItem["#{environment}"]["application"]
rpm_version = application['rpm_version']

user = application['user']
group = application['group']


log "seedvalue=#{seedvalue}" do
  level :info
end

log "dbweb=#{dbweb}" do
  level :info
end

log "dbdwh=#{dbdwh}" do
  level :info
end

log "rpm_version=#{rpm_version}" do
  level :info
end
