# -*- mode: ruby -*-
# vi: set ft=ruby :

# see also https://github.com/yandex-qatools/chef-selenium
# http://stackoverflow.com/questions/16879469/using-a-chef-recipe-to-append-multiple-lines-to-a-config-file

VAGRANTFILE_API_VERSION = '2'

vagrant_use_proxy = ENV['VAGRANT_USE_PROXY'].to_i 

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if vagrant_use_proxy == 1 

    http_proxy = nil 
    if ENV['HTTP_PROXY'] 
      http_proxy = ENV['HTTP_PROXY'] 
    end 
    if http_proxy
      if Vagrant.has_plugin?('vagrant-proxyconf')
        # https://github.com/tmatilai/vagrant-proxyconf
        # https://github.com/WinRb/vagrant-windows
        # A proxy should be specified in the form of http://[user:pass@]host:port.
        # without the domain part
        config.proxy.http     = http_proxy.gsub('%%','%')
        config.proxy.https    = http_proxy.gsub('%%','%')
        config.proxy.no_proxy = 'localhost,127.0.0.1'
      end
    end 
  end

  # do  not use precise32 or raring32:
  # Vagrant gets the error
  # apt-get update -y -qq
  # W: Failed to fetch http://security.ubuntu.com/ubuntu/dists/raring-security/main/source/Sources  404  Not Found
  # W: Failed to fetch http://security.ubuntu.com/ubuntu/dists/precise-security/universe/i18n/Translation-en_US  Unable to connect to security.ubuntu.com:http: [IP: 91.189.91.24 80]
  # ...
  # E: Some index files failed to download. They have been ignored, or old ones used instead.

  config.vm.box_url = 'file:///home/sergueik/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box' 
  #  config.vm.box_url = 'file://c:/Users/sergueik/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box' 
  # config.vm.box_url = 'http://files.vagrantup.com/precise64.box' 
  config.vm.box = 'ubuntu/trusty32'

  # config.vm.box_url = 'file:///media/Data/Vagrant/IE10.Win7.For.Vagrant.box' 
  # config.vm.box = 'IE10_W7'
  # https://gist.github.com/uchagani/48d25871e7f306f1f8af
  # https://groups.google.com/forum/#!topic/vagrant-up/PpRelVs95tM 
  if config.vm.box =~ /ubuntu|redhat|debian/ 
    config.vm.network 'forwarded_port', guest: 5901, host: 5901, id: 'vnc'
    config.vm.host_name = 'vagrant-chef'
  else
    config.vm.communicator = 'winrm'
    # Admin user name and password. Note that it was changed
    config.winrm.username = 'vagrant'
    config.winrm.password = 'vagrant'
    config.vm.guest = :windows
    config.windows.halt_timeout = 15
    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: 'rdp', auto_correct: true
    config.vm.network :forwarded_port, guest: 22, host: 2222, id: 'ssh', auto_correct: true
    config.vm.network :forwarded_port, guest: 5985, host: 5985, id: 'winrm', auto_correct:true
    config.vm.host_name = 'windows7'
    config.vm.boot_timeout = 120
    # Ensure that all networks are set to private
    config.windows.set_work_network = true
  end
  config.vm.network 'forwarded_port', guest: 4444, host: 4444, id: 'selenium', auto_correct:true
  config.vm.synced_folder './' , '/vagrant', disabled: true
  config.vm.provider 'virtualbox' do |v|
    v.memory = 1024
    v.cpus = 1 
    v.gui = false
  end
  # Linux node recipes
  if config.vm.box =~ /ubuntu|redhat|debian/ 

    config.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.add_recipe 'wrapper_java'
      chef.add_recipe 'wrapper_hostsfile'
      chef.add_recipe 'xvfb'
      chef.add_recipe 'vnc'
      chef.add_recipe 'selenium_hub'
      chef.add_recipe 'selenium_node'
      chef.log_level = 'info' 
    end 
  else 

  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = 'data_bags'
    chef.add_recipe 'base'
    chef.add_recipe 'windows'
    chef.add_recipe 'powershell'
    chef.add_recipe 'sample'
    # https://github.com/dhoer/chef-selenium
    # https://github.com/dhoer/chef-nssm
    chef.add_recipe 'chef-selenium'
    chef.add_recipe 'chef-nssm'
    
  end
  end
end
