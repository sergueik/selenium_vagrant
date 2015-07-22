# Introduction

Vagrant and Chef resources for setting up a box in Virtual Box running Java, Selenium, Spoon.Net, IE, Firefox, Phantom JS, and Chrome from Linux environment



## Environment 
Based on the `BOX_NAME` environment the following guest is created 

 - ubuntu32 
      base box with xvfb, xvnc, java runtime , selenium, firefox
 - ubuntu64
      base box with xvfb, xvnc, java runtime , selenium, firefox
 - centos65
      base box with docker, java runtime 
 - windows7
      base box with spoon, few spoon images  for selenium-grid and ie,9,10,11

The `BOX_GUI` is recognized to allow gui(less)mode  - important for spoon.Net testing (not very stable)
The `VAGRANT_USE_PROXY` together with `HTTP_PROXY` is standard environment to deal with firewall. 

## Open Items 
There is work in progress on adding chrome recipes to ubuntu, testing on centos, better error detection on windows7, especially  with spoon.Net layer

## Note 
There is a big number of dependency cookbooks. These are currently placed in the cookbooks directory - it is important that some (notably powershell and windows) cookbooks are snapshots of certain past version which is known to be the last stable. Warning - these are not maintained locally, but are likely to added to .gitignore. Occasuinally this may lead to a error in provisioning e.g. conflict between build-essential docker dependency that is processed on a windows guest as it were a mac.

|cookbook|dependency of 
| -------|:-------------:|
|apt
|aufs
|base
|build-essential
|chef-nssm
|chef-selenium
|chef_handler
|custom_cpan_modules
|databag_manager
|device-mapper
|dmg
|docker
|docker_registry
|dpkg_autostart
|firebug
|firefox
|git
|gitignote.txt
|golang
|homebrew
|hostsfile
|iptables
|iptables-ng
|java
|log4j
|lxc
|modules
|ms_dotnet2
|ms_dotnet4
|ms_dotnet45
|ohai
|polipo
|powershell
|python
|runit
|sample
|selenium
|selenium_hub
|selenium_node
|spoon
|sysctl
|tweak_proxy_settings
|vnc
|windows
|wrapper_hostsfile
|wrapper_java
|wrapper_yum
|xvfb
|yum
|yum-epel

