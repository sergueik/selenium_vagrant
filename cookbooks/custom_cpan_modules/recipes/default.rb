log 'installing CPAN modules' do
  level :info
end

# Define variables for attributes
account_username = node['vnc']['account_username'];
account_home = "/home/#{account_username}";
selenium_home = "#{account_home}/selenium"


node['custom_cpan_modules']['packages'].each do |name|
    package name
end

node['custom_cpan_modules']['modules'].each do |name|
 cpan_module name
end

cookbook_file "#{selenium_home}/basic.pl" do
  source 'basic.pl'
  path "#{selenium_home}/basic.pl"
  owner account_username
  mode  00644
  action :create_if_missing
end

# TODO: smoke test 

log 'Finished installing CPAN modules.' do
  level :info
end





