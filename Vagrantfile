# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box_url = 'http://files.vagrantup.com/precise64.box' 
  config.vm.box = 'hashicorp/precise64'

  # TODO : ubuntu/trusty32
  # vagrant up ubuntu/trusty32 --provider virtualbox

  config.vm.network 'forwarded_port', guest: 4444,  host: 4444
  config.vm.network 'forwarded_port', guest: 5901,  host: 5901
  config.vm.host_name = 'chef-book'
  config.vm.provider "virtualbox" do |v|
    v.memory = 1024
    v.cpus = 1
  end
  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = 'data_bags'
    # chef.add_recipe 'base'
    chef.add_recipe 'wrapper_java'
    # TODO : Berkshelf 
    chef.add_recipe 'xvfb'
	    chef.add_recipe 'vnc'
    chef.add_recipe 'selenium_hub'
    chef.add_recipe 'selenium_node'

    chef.log_level = 'info' 
  end
end
