# -*- mode: ruby -*-
# vi: set ft=ruby :

basedir = ENV.fetch('USERPROFILE', '')  
basedir = ENV.fetch('HOME', '') if basedir == ''
basedir = basedir.gsub('\\', '/')

vagrant_use_proxy = ENV.fetch('VAGRANT_USE_PROXY', nil)
http_proxy        = ENV.fetch('HTTP_PROXY', nil) 
box_name          = ENV.fetch('BOX_NAME', '') 
debug             = ENV.fetch('DEBUG', 'false') 
box_memory        = ENV.fetch('BOX_MEMORY', '') 
box_cpus          = ENV.fetch('BOX_CPUS', '') 
box_gui           = ENV.fetch('BOX_GUI', '') 
debug             = (debug =~ (/^(true|t|yes|y|1)$/i))

unless box_name =~ /\S/
  custom_vagrantfile = 'Vagrantfile.local'
  if File.exist?(custom_vagrantfile) 
    puts "Loading '#{custom_vagrantfile}'"
    # config = Hash[File.read(File.expand_path(custom_vagrantfile)).scan(/(.+?) *= *(.+)/)]
    config = {}
    File.read(File.expand_path(custom_vagrantfile)).split(/\n/).each do |line| 
      if line !~ /^#/
        key_val = line.scan(/^ *(.+?) *= *(.+) */)
        config.merge!(Hash[key_val])
      end
    end
    if debug
      puts config.inspect
    end
    box_name = config['box_name']
    box_gui = config['box_gui'] != nil && config['box_gui'].match(/(true|t|yes|y|1)$/i) != nil
    box_cpus = config['box_cpus'].to_i
    box_memory = config['box_memory'].to_i
  else
    # TODO: throw an error
  end
end 

if debug
  puts "box_name=#{box_name}"
  puts "box_gui=#{box_gui}"
  puts "box_cpus=#{box_cpus}"
  puts "box_memory=#{box_memory}"
end

VAGRANTFILE_API_VERSION = '2'

 
Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # Configure Proxy authentication

  if vagrant_use_proxy
    if http_proxy
    
      if Vagrant.has_plugin?('vagrant-proxyconf')
        # Windows-specific case
        # A proxy should be specified in the form of http://[user:pass@]host:port.
        # without the domain part and with percent signs doubled - Vagrant and Ruby still use batch files on Windows
        # https://github.com/tmatilai/vagrant-proxyconf
        # https://github.com/WinRb/vagrant-windows
        config.proxy.http     = http_proxy.gsub('%%','%')
        config.proxy.https    = http_proxy.gsub('%%','%')
        config.proxy.no_proxy = 'localhost,127.0.0.1'
      end
    end 
  end

# Localy cached images from
# http://www.vagrantbox.es/
# http://dev.modern.ie/tools/vms/linux/
# TODO: make precise the default
case box_name 
   when /centos6/ 
     config.vm.box = 'centos/65'
     config.vm.box_url = "file://#{basedir}/Downloads/centos-6.5-x86_64.box"
   when /centos7/ 
     config.vm.box = 'centos/7'
     config.vm.box_url = "file://#{basedir}/Downloads/centos-7.0-x86_64.box"
   when /trusty32/ 
     config.vm.box = 'ubuntu/trusty32'
     config.vm.box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box"
   when /trusty64/ 
     config.vm.box = 'ubuntu/trusty64'   
     config.vm.box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-amd64-vagrant-disk1.box"
     when /precise64/ 
     config.vm.box = 'ubuntu/precise64'
     config.vm.box_url = "file://#{basedir}/Downloads/precise-server-cloudimg-amd64-vagrant-disk1.box"
  else 
     config.vm.box = 'windows10'
     config.vm.box_url = "file://#{basedir}/Downloads/vagrant-win10-edge-default.box"
     # tweak modern.ie image into a vagrant manageable box
     # https://github.com/WinRb/vagrant-windows
     # https://gist.github.com/uchagani/48d25871e7f306f1f8af
     # https://groups.google.com/forum/#!topic/vagrant-up/PpRelVs95tM 
     # config.vm.box = 'windows7'
     # config.vm.box_url = "file://#{basedir}/Downloads/vagrant-win7-ie10-updated.box"
  end
  # Configure guest-specific port forwarding
  if config.vm.box !~ /windows/ 
    if config.vm.box =~ /centos/ 
      config.vm.network 'forwarded_port', guest: 8080, host: 8080, id: 'artifactory', auto_correct:true
    end
    config.vm.network 'forwarded_port', guest: 5901, host: 5901, id: 'vnc', auto_correct: true
    config.vm.host_name = 'vagrant-chef'
    config.vm.synced_folder './' , '/vagrant', disabled: true
  else
    # have to clear HTTP_PROXY to prevent
    # WinRM::WinRMHTTPTransportError: Bad HTTP response returned from server (503) 
    # https://github.com/chef/knife-windows/issues/143
    ENV.delete('HTTP_PROXY')
    # Note Windows Product Activation dialog  appears to block chef solo from doing anything and result in Vagrant failing with 
    # Chef never successfully completed!

    config.vm.communicator = 'winrm'
    config.winrm.username = 'vagrant'
    config.winrm.password = 'vagrant'
    config.vm.guest = :windows
    config.windows.halt_timeout = 15
    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: 'rdp', auto_correct: true
    config.vm.network :forwarded_port, guest: 5985, host: 5985, id: 'winrm', auto_correct:true
    config.vm.host_name = 'windows7'
    config.vm.boot_timeout = 120
    # Ensure that all networks are set to 'private'
    config.windows.set_work_network = true
    # on Windows, use default data_bags share
  end
  # Configure common port forwarding
  config.vm.network 'forwarded_port', guest: 4444, host: 4444, id: 'selenium', auto_correct:true
  config.vm.network 'forwarded_port', guest: 3000, host: 3000, id: 'reactor', auto_correct:true
  
  config.vm.provider 'virtualbox' do |vb|
    vb.gui = box_gui 
    vb.customize ['modifyvm', :id, '--cpus', box_cpus ]
    vb.customize ['modifyvm', :id, '--memory', box_memory ]
    vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
    vb.customize ['modifyvm', :id, '--accelerate3d', 'off']
    vb.customize ['modifyvm', :id, '--audio', 'none']
    vb.customize ['modifyvm', :id, '--usb', 'off']
  end

  # config.berkshelf.berksfile_path = 'cookbooks/wrapper_java/Berksfile'
  # config.berkshelf.enabled = true

  # Provision software
  case config.vm.box.to_s 
   when /ubuntu|debian/
    # Use chef provisioner with ubuntu
    config.vm.provision :chef_solo do |chef|
      # http://stackoverflow.com/questions/31149600/undefined-method-cheffish-for-nilnilclass-when-provisioning-chef-with-vagra
      # cheffish bug in 12.4.1
      chef.version = '12.3.0'
# provided by Berkshelf
#      chef.add_recipe 'chef-server'
    

      chef.data_bags_path = 'data_bags'
      chef.add_recipe 'wrapper_chrome'
      chef.add_recipe 'wrapper_java'
      chef.add_recipe 'wrapper_hostsfile'
      chef.add_recipe 'tweak_proxy_settings'
      # TODO - choose which X server to install
      chef.add_recipe 'xvfb'
      chef.add_recipe 'wrapper_vnc'
      chef.add_recipe 'selenium_hub'
      chef.add_recipe 'selenium_node'
      chef.add_recipe 'firebug'
      # NOTE: time-consuming
      # chef.add_recipe 'perl'
      # chef.add_recipe 'custom_cpan_modules'
      chef.log_level = 'info' 
    end
  when /centos/
    # Use shell provisioner with centos
    config.vm.provision 'shell', path: 'centos_common_provision.sh'
    # 1. Remove and install jdk from locally hosted artifactory repository      
    config.vm.provision 'shell', inline: <<END_SCRIPT1

export YUM_FLAG=-y

export JAVA_VERSION=$(java -version 2>& 1| head -1)
STATUS=$(expr "$JAVA_VERSION" : 'java version "\\(.*\\)"')
if [ "$STATUS" != "" ] ; then
# TODO - stop if the desired Java version / flavour is already present

# java is present on the box -  remove it
export JAVA_YUM_INSTALLED_PACKAGE_VERSION=$(yum list installed | grep jdk|head -1)
if [ "$JAVA_YUM_INSTALLED_PACKAGE_VERSION" != "" ]; then

# Remove jdk through yum

yum remove ${YUM_FLAG} "$JAVA_YUM_INSTALLED_PACKAGE_VERSION"
fi
fi

END_SCRIPT1

    # 2. Provision Latest Docker
    config.vm.provision 'shell', inline: 'sudo yum -y install docker-io'

    # 3. Add Artifactory Docker Registry
    config.vm.provision 'file', source: '.dockercfg', destination: '~/.dockercfg'
    # 4. Setup local artifactory repo - unfinished 
    config.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.add_recipe 'wrapper_yum'
    end
  else
    # Use chef provisioner and powershell with windows
    config.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.add_recipe 'custom_nuget'
      chef.add_recipe 'custom_powershell'
      # chef.add_recipe 'abcpdf'
      chef.log_level = 'info' 
    end
  end
end

