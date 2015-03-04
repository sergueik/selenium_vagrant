# -*- mode: ruby -*-
# vi: set ft=ruby :

# see also https://github.com/yandex-qatools/chef-selenium
# http://stackoverflow.com/questions/16879469/using-a-chef-recipe-to-append-multiple-lines-to-a-config-file

VAGRANTFILE_API_VERSION = '2'

vagrant_use_proxy = ENV['VAGRANT_USE_PROXY'].to_i 

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if vagrant_use_proxy == 1 
    # stabilizer  
    # puts  'Set proxy'
    #  Cannot initiate the connection to us.archive.ubuntu.com:80 (2001:67c:1562::13)
    # . - connect (101: Network is unreachable) [IP: 2001:67c:1562::13 80]
    # root@chef-book:~# ps ax |  grep ap[t]
    #  2286 ?        R      0:00 apt-cache policy openjdk-6-jdk
    # root@chef-book:~# ps ax |  grep ap[t]
    #  2296 ?        S      0:00 apt-get -q -y install openjdk-6-jdk=6b34-1.13.6-1ubuntu0.12.04.1
    #  8807 ?        S      0:00 apt-get -q -y install xvfb=2:1.11.4-0ubuntu10.17
    #  8838 ?        S      0:00 /usr/bin/dpkg --status-fd 57 --unpack --auto-deconfigure /var/cache/apt/archives/libllvm3.0_3.0-4ubuntu1_amd64.deb /var/cache/apt/arc...

    http_proxy = nil 
    if ENV['HTTP_PROXY'] 
      http_proxy = ENV['HTTP_PROXY'] 
    end 
    if http_proxy
      if Vagrant.has_plugin?('vagrant-proxyconf')
        # https://github.com/tmatilai/vagrant-proxyconf
        # https://github.com/WinRb/vagrant-windows
        # A proxy should be specified in the form of http://[user:pass@]host:port.
        # without the AD domain part
        config.proxy.http     = http_proxy.gsub('%%','%')
        config.proxy.https    = http_proxy.gsub('%%','%')
      
        # NOTE - when a domain is set as part of the user name,  a 
        # C:/vagrant/embedded/lib/ruby/2.0.0/uri/common.rb:176:in `split': 
        # bad URI(is notURI?): (URI::InvalidURIError) is produced 
        # Communication with Selenium to bypass proxy.
        config.proxy.no_proxy = 'localhost,127.0.0.1'
      end
    end 
  end

  # do  not use precise32 or raring32:
  # Vagrant assumes that this means the command failed!
  # apt-get update -y -qq
  # Stdout from the command:
  # Stderr from the command:
  # stdin: is not a tty
  # W: Failed to fetch http://security.ubuntu.com/ubuntu/dists/raring-security/main/source/Sources  404  Not Found
  # W: Failed to fetch http://security.ubuntu.com/ubuntu/dists/precise-security/universe/i18n/Translation-en_US  Unable to connect to security.ubuntu.com:http: [IP: 91.189.91.24 80]
  # ...
  # E: Some index files failed to download. They have been ignored, or old ones used instead.

  config.vm.box_url = 'file://c:/Users/sergueik/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box  ' 
  config.vm.box = 'ubuntu/trusty32'
  #  default: Adding box 'ubuntu/trusty32' (v0) for provider: virtualbox
  #  default: Downloading: https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-i386-vagrant-disk1.box
  #  default: Progress: 0% (Rate: 0/s, Estimated time remaining: --:--:--)
  #  An error occurred while downloading the remote file. The error message, if any, is reproduced below. Please fix this error and try again.
  #  
  #  Failed connect to cloud-images.ubuntu.com:443; No error
  #  
  # Note:  download time via browser is 30 min  
  # TODO 

  # config.vm.box_url = 'http://files.vagrantup.com/precise64.box' 
  #  config.vm.box = 'hashicorp/precise64'
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
  # Linux node recipes
  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = 'data_bags'
    chef.add_recipe 'wrapper_java'
    chef.add_recipe 'xvfb'
    chef.add_recipe 'vnc'
    chef.add_recipe 'selenium_hub'
    chef.add_recipe 'selenium_node'
    chef.log_level = 'info' 
  end
end
