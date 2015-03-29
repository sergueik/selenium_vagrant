# -*- mode: ruby -*-
# vi: set ft=ruby :

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



  # config.vm.box_url = 'file:///home/sergueik/Downloads/centos-6.5-x86_64.box' 
  # config.vm.box_url = 'file://c:/Users/sergueik/Downloads/centos-6.5-x86_64.box'
  # config.vm.box = 'centos65'

  # config.vm.box_url = 'file:///home/sergueik/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box' 
  #  config.vm.box_url = 'file://c:/Users/sergueik/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box' 
  # config.vm.box = 'ubuntu/trusty32'


  config.vm.box_url = 'file:///home/sergueik/Downloads/precise-server-cloudimg-amd64-vagrant-disk1.box' 
  #  config.vm.box_url = 'file://c:/Users/sergueik/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box' 
  config.vm.box = 'ubuntu/precise64'

  # config.vm.box_url = 'file:///home/sergueik/Downloads/vagrant-win7-ie10-updated.box' 
  # config.vm.box_url = 'file://c:/Users/sergueik/Downloads/vagrant-win7-ie10-updated.box'

  # config.vm.box = 'windows7'
  # https://gist.github.com/uchagani/48d25871e7f306f1f8af
  # https://groups.google.com/forum/#!topic/vagrant-up/PpRelVs95tM 

  if config.vm.box =~ /ubuntu|redhat|debian|centos/ 
    config.vm.network 'forwarded_port', guest: 5901, host: 5901, id: 'vnc'
    config.vm.host_name = 'vagrant-chef'
  else
    config.vm.communicator = 'winrm'
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

  case config.vm.box.to_s 
  # Linux node recipes
   when /ubuntu|debian/ 

    config.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.add_recipe 'wrapper_java'
      chef.add_recipe 'wrapper_hostsfile'
      chef.add_recipe 'tweak_proxy_settings'
      chef.add_recipe 'selenium'
      chef.add_recipe 'xvfb'
      chef.add_recipe 'vnc'
      chef.add_recipe 'selenium_hub'
      chef.add_recipe 'selenium_node'
      chef.add_recipe 'firebug'
      chef.log_level = 'info' 
    end
  when /centos/ 
    # use shell provisioner
    # Turn off firewall
    config.vm.provision "shell", inline: "chkconfig iptables off"
 
    # Provision update yum repositories
    config.vm.provision "shell", inline: "sudo yum -y update"

    # Provision new glibc
    config.vm.provision "shell", inline: "sudo yum -y install glibc.i686"
    
    # Provision misc tools
    config.vm.provision "shell", inline: "sudo yum install -y vim man-1.6f-32.el6 git-1.7.1-3.el6_4.1 wget-1.12-1.8.el6"
    
    # Provision Grab "Development Tools" for needed for compiling software from sources
    config.vm.provision "shell", inline: 'sudo yum -y groupinstall "Development Tools"'
 
    # Provision GNU screen
    config.vm.provision "shell", inline: "sudo yum -y install screen-4.0.3-16.el6"
 
    # Adding the EPEL
    config.vm.provision "shell", inline: "sudo yum -y install epel-release-6-8.noarch"

    # Provision Latest Docker
    config.vm.provision "shell", inline: "sudo yum -y install docker-io"

    # Add Artifactory Docker Registry
    # config.vm.provision "file", source: ".dockercfg", destination: "~/.dockercfg" 
  else 
  # Windows node recipes
    config.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.add_recipe 'spoon'
    end
  end
end
