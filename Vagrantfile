# -*- mode: ruby -*-
# vi: set ft=ruby :

# see also https://github.com/yandex-qatools/chef-selenium
# http://stackoverflow.com/questions/16879469/using-a-chef-recipe-to-append-multiple-lines-to-a-config-file

VAGRANTFILE_API_VERSION = '2'
VAGRANT_USE_PROXY = 1 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if VAGRANT_USE_PROXY
    if Vagrant.has_plugin?('vagrant-proxyconf')
      # https://github.com/tmatilai/vagrant-proxyconf
      # A proxy should be specified in the form of http://[user:pass@]host:port.
      # without the domain part
      config.proxy.http     = 'http://sergueik:<URL-endoded PASSWORD>@proxy.carnival.com:8080'
      config.proxy.https    = 'http://sergueik:<URL-endoded PASSWORD>@proxy.carnival.com:8080'
      # NOTE - 
      # C:/vagrant/embedded/lib/ruby/2.0.0/uri/common.rb:176:in `split': 
      # bad URI(is notURI?): http://carnival%5Csergueik:.....
      # validURIError)
      # Communication with Selenium to bypass proxy.
      config.proxy.no_proxy = 'localhost,127.0.0.1'
    end
  end
  config.vm.box_url = 'http://files.vagrantup.com/precise64.box' 
  config.vm.box = 'hashicorp/precise64'

  # TODO : ubuntu/trusty32
  # vagrant up ubuntu/trusty32 --provider virtualbox
  # Selenium HUB 
  config.vm.network 'forwarded_port', guest: 4444,  host: 4444
  # VNC 
  config.vm.network 'forwarded_port', guest: 5901,  host: 5901
  config.vm.host_name = 'chef-book'

  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end
  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = 'data_bags'
    chef.add_recipe 'base'
    chef.add_recipe 'wrapper_java'
    chef.add_recipe 'xvfb'
    chef.add_recipe 'vnc'
    chef.add_recipe 'selenium_hub'
    chef.add_recipe 'selenium_node'
    chef.add_recipe 'databag_manager'
    chef.log_level = 'info' 
  end
end
