# -*- mode: ruby -*-
# vi: set ft=ruby :


VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

config.vm.box_url = 'http://files.vagrantup.com/precise64.box' 
config.vm.box = 'hashicorp/precise64'

$script = <<-SCRIPT

# Install chef via vagrant 

apt-get update

DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

apt-get install git-core curl build-essential zlib1g-dev libssl-dev libreadline6-dev libyaml-dev libxml2-dev libxsl2-dev -y

echo 'America/New York' > /etc/timezone 
dpkg-reconfigure -f noninteractive tzdata

if ! [ -x /usr/bin/chef ]; then
  cd /tmp
  rm -rf *deb*
  # TODO upgrade to 0.4.0 omnibus package
  wget --no-check-certificate --quiet https://opscode-omnibus-packages.s3.amazonaws.com/ubuntu/12.04/x86_64/chefdk_0.3.5-1_amd64.deb

  dpkg -i chefdk_0.3.5-1_amd64.deb

fi
# some latest packages require ruby 2.x.x
# http://stackoverflow.com/questions/16222738/how-do-i-install-ruby-2-0-0-correctly-on-ubuntu-12-04
# install chef 
if ! [ -a /etc/chef/client.pem ]; then
  curl -L https://www.opscode.com/chef/install.sh | sudo bash
fi
ntpdate tick.uh.edu
  SCRIPT
  config.vm.network 'forwarded_port', guest: 4444,  host: 4444
  config.vm.network 'forwarded_port', guest: 5901,  host: 5901
  config.vm.host_name = 'chef-book'
  # comment execution shell provisioner before the chef takes over
  # config.vm.provision :shell, :inline => $script
config.vm.provider "virtualbox" do |v|
  v.memory = 1024
  v.cpus = 1
end
  config.vm.provision :chef_solo do |chef|
    chef.data_bags_path = 'data_bags'
    chef.add_recipe 'base'
    chef.add_recipe 'java'
    chef.add_recipe 'xvfb'
    chef.add_recipe 'selenium_hub'
    chef.add_recipe 'selenium_node'
    chef.add_recipe 'vnc'
    chef.log_level = 'debug' 
  end
end
