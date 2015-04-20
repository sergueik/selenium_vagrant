# -*- mode: ruby -*-
# vi: set ft=ruby :

# Custom environment settings to enable this Vagrantfile to boot various flavours of Linux or Windows from Linux or Windows host
vagrant_use_proxy = ENV.fetch('VAGRANT_USE_PROXY', nil)
http_proxy = ENV.fetch('HTTP_PROXY', nil) 
box_name = ENV.fetch('BOX_NAME', 'ubuntu/precise64') 
basedir =  ENV.fetch('USERPROFILE', '')  
basedir  = ENV.fetch('HOME', '') if basedir == ''
basedir = basedir.gsub('\\', '/')

box_memory = ENV.fetch('BOX_MEMORY', '1024') 
box_cpus = ENV.fetch('BOX_CPUS', '1') 
box_gui = ENV.fetch('BOX_GUI', 'false') 

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

# Locate the box
case box_name 
   when /centos65/ 
     config.vm.box_url = "file://#{basedir}/Downloads/centos-6.5-x86_64.box"
     config.vm.box = 'centos65'
   when /trusty32/ 
     config.vm.box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box"
     config.vm.box = 'ubuntu/trusty32'
   when /trusty64/ 
     config.vm.box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-amd64-vagrant-disk1.box"
     config.vm.box = 'ubuntu/trusty64'
   when /precise64/ 
     config.vm.box_url = "file://#{basedir}/Downloads/precise-server-cloudimg-amd64-vagrant-disk1.box"
     config.vm.box = 'ubuntu/precise64'
  else 
     # For Windows use tweaked modern.ie box
     # To change Windows into a vagrant manageable box see
     # https://gist.github.com/uchagani/48d25871e7f306f1f8af
     # https://groups.google.com/forum/#!topic/vagrant-up/PpRelVs95tM 
     config.vm.box_url = "file://#{basedir}/Downloads/vagrant-win7-ie10-updated.box"
     config.vm.box = 'windows7'
  end
  # Configure guest-specific port forwarding
  if config.vm.box =~ /ubuntu|redhat|debian|centos/ 
    config.vm.network 'forwarded_port', guest: 5901, host: 5901, id: 'vnc', auto_correct: true
    config.vm.host_name = 'vagrant-chef'
    config.vm.synced_folder './' , '/vagrant', disabled: true
  else
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
  
  config.vm.provider 'virtualbox' do |vb|
    vb.gui = box_gui
    vb.customize ['modifyvm', :id, '--cpus', box_cpus ]
    vb.customize ['modifyvm', :id, '--memory', box_memory ]
    vb.customize ['modifyvm', :id, '--clipboard', 'bidirectional']
    vb.customize ['modifyvm', :id, '--accelerate3d', 'off']
    vb.customize ['modifyvm', :id, '--audio', 'none']
    vb.customize ['modifyvm', :id, '--usb', 'off']
  end

  # Provision software
  case config.vm.box.to_s 
   # Use chef provisioner with ubuntu
   when /ubuntu|debian/ 
    config.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.add_recipe 'wrapper_java'
      chef.add_recipe 'wrapper_hostsfile'
      chef.add_recipe 'tweak_proxy_settings'
      # TODO - choose which X server to install
      chef.add_recipe 'xvfb'
      chef.add_recipe 'vnc'
      chef.add_recipe 'selenium_hub'
      chef.add_recipe 'selenium_node'
      chef.add_recipe 'firebug'
      chef.log_level = 'info' 
    end
  # Use shell provisioner with centos
  when /centos/ 

    # Turn off firewall
    config.vm.provision 'shell', inline: 'chkconfig iptables off'

    # Provision update yum repositories
    config.vm.provision 'shell', inline: 'sudo yum -y update'

    # Provision new glibc
    config.vm.provision 'shell', inline: 'sudo yum -y install glibc.i686'
    
    # Provision misc tools
    config.vm.provision 'shell', inline: 'sudo yum install -y vim man-1.6f-32.el6 git-1.7.1-3.el6_4.1 wget-1.12-1.8.el6'
    
    # Provision Grab "Development Tools" for needed for compiling software from sources
    config.vm.provision 'shell', inline: 'sudo yum -y groupinstall "Development Tools"'
 
    # Provision GNU screen
    config.vm.provision 'shell', inline: 'sudo yum -y install screen-4.0.3-16.el6'
 
    # Adding the EPEL
    config.vm.provision 'shell', inline: 'sudo yum -y install epel-release-6-8.noarch'

    # Provision Latest Docker
    config.vm.provision 'shell', inline: 'sudo yum -y install docker-io'

    # Add Artifactory Docker Registry
    config.vm.provision 'file', source: '.dockercfg', destination: '~/.dockercfg'

    # Remove and install jdk from locally hosted artifactory repository - unfinished
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
  # For Windows use Chef and Powershell provisioner - unfinished
  else 
    
    config.vm.provision :chef_solo do |chef|
      chef.data_bags_path = 'data_bags'
      chef.add_recipe 'spoon'
      chef.log_level = 'info' 
    end
  end
end

# VAGRANT_LOG=debug vagrant up > debug.log 2>&1
