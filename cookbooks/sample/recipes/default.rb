
%w[build-essential openssl libreadline6 libreadline6-dev  libxslt1-dev libxml2-dev].each do
|p| 
package p 
end

chef_gem 'nokogiri' do
  action :install
end
