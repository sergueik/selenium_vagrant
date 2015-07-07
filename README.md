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


## Open Items 
There is work in progress on adding chrome recipes to ubuntu, testing on centos, better error detection on windows7, especially  with spoon.Net layer

## Note 
The dependency cookbooks are often stashed in the cookbooks directory es.eciall when a snapshot of certain past version is known to be the last stable (e.g. with powershell and windows cookbooks). Watning - these are not maintained locally, but are likely to added to .gitignore

apt
aufs
base
build-essential
chef-nssm
chef-selenium
chef_handler
custom_cpan_modules
databag_manager
device-mapper
dmg
docker
docker_registry
dpkg_autostart
firebug
firefox
git
gitignote.txt
golang
homebrew
hostsfile
iptables
iptables-ng
java
log4j
lxc
modules
ms_dotnet2
ms_dotnet4
ms_dotnet45
ohai
polipo
powershell
python
runit
sample
selenium
selenium_hub
selenium_node
spoon
sysctl
tweak_proxy_settings
vnc
windows
wrapper_hostsfile
wrapper_java
wrapper_yum
xvfb
yum
yum-epel


