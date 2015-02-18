################################################################################
#
# Copyright (c) 2013 IBM Corporation and other Contributors
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
#
# Contributors:
#     IBM - initial implementation
#
################################################################################
#
# Recipe vnc::server
#
# Installs VNC server, desktop and browser for a complete remote desktop.
#
################################################################################


log "Installing VNC Server, desktop and browser" do
  level :info
end

# Define variables for attributes
geometry         = node['vnc']['geometry'];
account_username = node['vnc']['account_username'];
vnc_password     = node['vnc']['password'];
account_home     = "/home/#{account_username}";
password_file    = "#{account_home}/.vnc/passwd";

# Ensure apt-get is updated before running the script
execute "apt-get-update" do
  command "apt-get update"
  ignore_failure true
end

# Install xorg
package "Install xorg" do
  package_name 'xorg'
end

# Install LXDE core
package "Install LXDE core" do
  package_name 'lxde-core'
end

# Install Tight VNC server
package "Install TightVNC Server" do
  package_name 'tightvncserver'
end

# Ensure user exists 
user "Create user #{account_username} to be used for running VNC and the desktop" do
  action :create
  shell '/bin/bash'
  home "#{account_home}"
  supports :manage_home => true
  username "#{account_username}"
end

# Add user to the sudo group.
group 'sudo' do
  members "#{account_username}"
  action :modify
  append true
end

# Ensure that the user's .vnc directory exists.
directory 'Create .vnc directory' do
  user "#{account_username}"
  group "#{account_username}"
  action :create
  recursive true
  path "#{account_home}/.vnc"
end 

# TODO: Copy / produce  the .Xauthority

# Ensure ownership of the VNC password file
cookbook_file "#{password_file}" do
  source 'passwd'
  user "#{account_username}"
  user "#{account_username}"
  action :create_if_missing
  mode 00600
end

# Set VNC password for the user.
# Currently done manually after this recipe is complete when starting the vncserver service 
execute 'Create VNC password file' do
  user "#{account_username}"
  command "echo #{vnc_password}| /usr/bin/vncpasswd -f > #{password_file}" 
end

#
# Ensure ownership of the passwd file
# execute "Ensure ownership of the VNC password file #{password_file}" do
#  user "#{account_username}"
#  command "chown #{account_username}:#{account_username} #{password_file} && chmod 0600 #{password_file}" 
# end


# Create a vncserver service script.
template "/etc/init.d/vncserver" do
  source "VNCService.erb"
  mode "0775"
  owner "root"
  group "root"
  variables({
             :user_name	=> "#{account_username}",
             :display	=> "1",
             :geometry	=> "#{geometry}",
             :depth	=> "16"
           })
end

# Create the xstartup script
file "#{account_home}/.vnc/xstartup" do
  user "#{account_username}"
  group "#{account_username}"
  action :create
  mode "0755"
  content  "#!/bin/sh
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
/usr/bin/startlxde
"
end

# Enable the VNC server service
# Starting of the service needs to be done manually after the recipe is complete.
#  action [:enable, :start]
service "vncserver" do
  supports :restart => true
  ignore_failure false
  action [:start, :enable]
end

log "Finished configuring VNC server.  Now SSH to the server as root and run \"service vncserver start\"" do
  level :info
end
