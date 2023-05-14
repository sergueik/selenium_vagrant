# -*- mode: ruby -*-
# vi: set ft=ruby :

basedir = ENV.fetch('USERPROFILE', '')
basedir = ENV.fetch('HOME', '') if basedir == ''
basedir = basedir.gsub('\\', '/')

vagrant_use_proxy = ENV.fetch('VAGRANT_USE_PROXY', nil)
http_proxy        = ENV.fetch('HTTP_PROXY', nil)
box_name          = ENV.fetch('BOX_NAME', '')
debug             = ENV.fetch('DEBUG', 'false')
box_memory        = ENV.fetch('BOX_MEMORY', '1024')
box_cpus          = ENV.fetch('BOX_CPUS', '2')
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

  # Localy cached images
  case box_name

    when /centos65_i386/
      config_vm_box     = 'centos'
      config_vm_default = 'linux'
      config_vm_box_url = "file://#{basedir}/Downloads/centos_6-5_i386.box"
    when /centos66_x64/
      config_vm_box     = 'centos'
      config_vm_default = 'linux'
      # https://github.com/tommy-muehle/puppet-vagrant-boxes/releases/download/1.0.0/centos-6.6-x86_64.box
      config_vm_box_url = "file://#{basedir}/Downloads/centos-6.6-x86_64.box"
    when /centos7/
      config_vm_box     = 'centos'
      config_vm_default = 'linux'
      config_vm_box_url = "file://#{basedir}/Downloads/centos-7.0-x86_64.box"
    when /trusty32/
      config_vm_box     = 'ubuntu'
      config_vm_box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-i386-vagrant-disk1.box"
    when /trusty64/
      config_vm_box     = 'ubuntu'
      config_vm_default = 'linux'
      config_vm_box_url = "file://#{basedir}/Downloads/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    when /precise64/
      config_vm_box     = 'ubuntu'
      config_vm_default = 'linux'
      # config_vm_box_url = "file://#{basedir}/Downloads/precise-server-cloudimg-amd64-vagrant-disk1.box"
      config_vm_box_url = "file://#{basedir}/Downloads/ubuntu-server-12042-x64-vbox4210.box"
   else
     config_vm_default = 'windows'
     config_vm_newbox  = false
     if box_name =~ /xp/
       config_vm_box     = 'windows_xp'
       config_vm_box_url = "file://#{basedir}/Downloads/IE8.XP.For.Vagrant.box"
     elsif box_name =~ /2008/
       config_vm_box     = 'windows_2008'
       config_vm_box_url = "file://#{basedir}/Downloads/windows-2008R2-serverstandard-amd64_virtualbox.box"
     elsif box_name =~ /2012/
       config_vm_box     = 'windows_2012'
       config_vm_box_url = "file://#{basedir}/Downloads/windows_2012_r2_standard.box"
     else
      config_vm_box     = 'windows7'
      config_vm_box_url = "file://#{basedir}/Downloads/vagrant-win7-ie10-updated.box"
     end
  end

  config.vm.define config_vm_default do |config|
    config.vm.box = config_vm_box
    config.vm.box_url  = config_vm_box_url
    puts "Configuring '#{config.vm.box}'"
    # Configure guest-specific port forwarding
    if config.vm.box !~ /windows/
      if config.vm.box =~ /centos/
        config.vm.network 'forwarded_port', guest: 8080, host: 8080, id: 'artifactory', auto_correct:true
      end
      config.vm.network 'forwarded_port', guest: 5901, host: 5901, id: 'vnc', auto_correct: true
      config.vm.host_name = 'linux.example.com'
      config.vm.hostname = 'linux.example.com'
    else
      # clear HTTP_PROXY to prevent
      # WinRM::WinRMHTTPTransportError: Bad HTTP response returned from server (503)
      # https://github.com/chef/knife-windows/issues/143
      ENV.delete('HTTP_PROXY')
      # NOTE: WPA dialog blocks chef solo and makes Vagrant fail on modern.ie box
      config.vm.communicator      = 'winrm'
      config.winrm.username       = 'vagrant'
      config.winrm.password       = 'vagrant'
      config.vm.guest             = :windows
      config.windows.halt_timeout = 15
      # Port forward WinRM and RDP
      config.vm.network :forwarded_port, guest: 3389, host: 3389, id: 'rdp', auto_correct: true
      config.vm.network :forwarded_port, guest: 5985, host: 5985, id: 'winrm', auto_correct:true
      config.vm.host_name         = 'windows7'
      config.vm.boot_timeout      = 120
      # Ensure that all networks are set to 'private'
      config.windows.set_work_network = true
      # on Windows, use default data_bags share
    end
    # Configure common synced folder
    config.vm.synced_folder './' , '/vagrant'
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

    # Provision software
    puts "Provision software for '#{config.vm.box}'"
    case config_vm_box
      when /centos/
        # Use puppet provisioner with centos:
        # https://forge.puppetlabs.com/BernardoSilva/xvfb
        # https://forge.puppetlabs.com/p0deje/display
        # https://forge.puppetlabs.com/arusso/vnc
        # https://forge.puppetlabs.com/runthebusiness/tightvncserver
        # https://forge.puppetlabs.com/puppetlabs/java
        # https://forge.puppetlabs.com/jhoblitt/selenium
        # https://forge.puppetlabs.com/danielgil/log4j
        # https://forge.puppetlabs.com/elasticsearch/logstash
      when /ubuntu|debian/

        # NOTE:  need to install libgconf2-4 needed by chrome
        # currently the node provisioned through chef recipes
        # Use chef provisioner with ubuntu
        config.vm.provision :chef_solo do |chef|
          # for cheffish bug in 12.4.1 see
          # http://stackoverflow.com/questions/31149600/undefined-method-cheffish-for-nilnilclass-when-provisioning-chef-with-vagra
          # chef.version = '12.3.0'
          chef.version = '13.10.4'
          chef.data_bags_path = 'data_bags'
          [ 
            'wrapper_chrome',
            'wrapper_java',
            'wrapper_hostsfile',
            # NOTE: time-consuming
            # 'perl',
            # 'custom_cpan_modules',
            'tweak_proxy_settings',
            # 'selenium',
            'xvfb',
            # TODO: fix dependency error with groovy-2.4.5.zip
            # 'wrapper_vnc',
            # NOTE: there is a dependency between xvfb and wrapper_vnc cookbooks 
            # in 'account_username'
            'selenium_hub',
            'selenium_node',
            'firebug',
            # 'wrapper_groovy',
            #  'wrapper_maven',
            # 'wrapper_gradle',
          ].each do |recipe|
            chef.add_recipe recipe
          end
          # dependency cookbooks listed below for the refence
          
            # abcpdf/
            # ark/
            # build-essential/
            # chef_handler/
            # chrome/
            # custom_cpan_modules/
            # custom_nuget/
            # custom_powershell/
            # databag_manager/
            # dmg/
            # firebug/
            # gnome/
            # google-chrome/
            # gradle/
            # groovy/
            # homebrew/
            # hostsfile/
            # java/
            # log4j/
            # maven/
            # mingw/
            # ms_dotnet2/
            # ms_dotnet4/
            # ms_dotnet45/
            # powershell/
            # sample/
            # selenium/
            # selenium_hub/
            # selenium_maven/
            # selenium_node/
            # seven_zip/
            # spoon/
            # tweak_proxy_settings/
            # vnc/
            # windows/
            # wrapper_chrome/
            # wrapper_groovy/
            # wrapper_hostsfile/
            # wrapper_java/
            # wrapper_vnc/
            # wrapper_yum/
            # xvfb/
            # x-windows/

          # NOTE: time-consuming
          # chef.add_recipe 'perl'
          # chef.add_recipe 'custom_cpan_modules'
          chef.log_level = 'info'
        end
      else # windows
        if config_vm_newbox
          config.vm.provision :shell, inline: <<-EOF
            set-executionpolicy Unrestricted
            enable-remoting -Force
          EOF
          # install .Net 4
          config.vm.provision :shell, :path => 'install_net4.ps1'
          # install chocolatey
          config.vm.provision :shell, :path => 'install_chocolatey.ps1'
          # install puppet using chocolatey
          config.vm.provision :shell, :path => 'install_puppet.ps1'
        end
        # Use puppet provisioner
        config.vm.provision :puppet do |puppet|
          puppet.binary_path    = 'C:/PROGRA~1/PUPPET~1/PUPPET/bin'
          # puppet.binary_path    = 'C:/Program Files/Puppet Labs/Puppet/bin'
          puppet.hiera_config_path = 'data/hiera.yaml'
          puppet.module_path    = 'modules'
          puppet.manifests_path = 'manifests'
          puppet.manifest_file  = 'windows.pp'
          puppet.options        = '--verbose'
          # TODO: http://puppet-on-the-edge.blogspot.com/2014/03/heredoc-is-here.html
          # puppet.options        = '--verbose --parser'
        end
      end
    end
  end
