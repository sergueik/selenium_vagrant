# -*- mode: ruby -*-
# vi: set ft=ruby :

# see also https://github.com/yandex-qatools/chef-selenium
# http://stackoverflow.com/questions/16879469/using-a-chef-recipe-to-append-multiple-lines-to-a-config-file

VAGRANTFILE_API_VERSION = '2'

VAGRANT_USE_PROXY = 0 

env_name = 'HTTP_PROXY'
http_proxy = nil 
if VAGRANT_USE_PROXY
  if ENV[env_name] 
    http_proxy = ENV[env_name] 
  end 
end 

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if VAGRANT_USE_PROXY
    if Vagrant.has_plugin?('vagrant-proxyconf')
      # https://github.com/tmatilai/vagrant-proxyconf
      # https://github.com/WinRb/vagrant-windows
      # A proxy should be specified in the form of http://[user:pass@]host:port.
      # without the NTLM domain part
      config.proxy.http     = http_proxy.gsub('%%','%')
      config.proxy.https    = http_proxy.gsub('%%','%')
      
      # NOTE - when a domain is set as part of the user name,  a 
      # C:/vagrant/embedded/lib/ruby/2.0.0/uri/common.rb:176:in `split': 
      # bad URI(is notURI?): (URI::InvalidURIError) is produced 
      # Communication with Selenium to bypass proxy.
      config.proxy.no_proxy = 'localhost,127.0.0.1'
    end
  end

# do  not use precise32
 config.vm.box_url = 'http://files.vagrantup.com/precise64.box' 
  config.vm.box = 'hashicorp/precise64'
  # Selenium HUB 
  config.vm.network 'forwarded_port', guest: 4444,  host: 4444
  # VNC 
  config.vm.network 'forwarded_port', guest: 5901,  host: 5901
  config.vm.host_name = 'chef-book'
  config.vm.provider 'virtualbox' do |v|
    v.memory = 1024
    v.cpus = 1 
    # first time only for thoubleshooting , discoverd no VT
    v.gui = false
  end
  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = 'data_bags'
    chef.add_recipe 'base'
    chef.add_recipe 'wrapper_java'
    chef.add_recipe 'xvfb'
    chef.add_recipe 'vnc'
    chef.add_recipe 'selenium_hub'
    chef.add_recipe 'selenium_node'
#    chef.add_recipe 'databag_manager'
    chef.log_level = 'info' 
  end
end
