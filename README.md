### Intro

This project contains Vagrant and Chef resources for setting up a box in Virtual Box running Java, Selenium, Firefox, Phantom JS, and Chrome under Linux
and under Windows 7 with Spoon.Net and Selenium, Firefox, Chrome and IE (more about IE versions below).

### Environment
Based on the `BOX_NAME` environment the following base box is used

 - __ubuntu 12.04__, __ubuntu 14.05__ (*32-* and *64-bit*)
      base box with xvfb, xvnc, java runtime , selenium, firefox
 - __centos 65__
      base box with docker, java runtime
 - __centos 7__
      unfinished
 - __windows 7__
      base box with spoon, exploring available spoon images for selenium-grid and ie,9,10,11

The `BOX_GUI` environment setting is to toggle the gui(less)mode - important on windows box for spoon.Net testing , though not very stable.

The `VAGRANT_USE_PROXY` environment entry together with `HTTP_PROXY` are helpful to deal with firewall development machine setting.

### Open Items
There is work in progress on adding chrome recipes to ubuntu, testing on centos, better error detection on windows7, especially with spoon.Net layer.

### Note

There is a rich collection of bare bones Windows [Vagrant boxes](https://github.com/markhuber/modern-ie-vagrant) and Packer [image templates](https://github.com/joefitzgerald/packer-windows) based on images officially distributed by [Microsot](https://developer.microsoft.com/en-us/microsoft-edge/tools/vms/) intended primarily for browser testing in speciic releases of the Internet Explorer. These boxes, especiallyolder ones, vary in how well winrm automation  is supported "out of the box". Practically every one of those base boxes is somewhat large: multi-gigabyte.

With Chef, a big number of dependency cookbooks, especially with centos, is required. These are currently placed in the cookbooks directory which is
added to `.gitignore`: `apt`, `aufs`, `base`, `build-essential`, `chef-nssm`, `chef-selenium`, `chef_handler`, `custom_cpan_modules`, `databag_manager`, `device-mapper`, `dmg`, `docker`, `docker_registry`, `dpkg_autostart`, `firebug`, `firefox`, `git`, `gitignote.txt`, `golang`, `homebrew`, `hostsfile`, `iptables`, `iptables-ng`, `java`, `log4j`, `lxc`, `modules`, `ms_dotnet2`, `ms_dotnet4`, `ms_dotnet45`, `ohai`, `polipo`, `powershell`, `python`, `runit`, `sample`, `selenium`, `selenium_hub`, `selenium_node`, `spoon`, `sysctl`, `tweak_proxy_settings`, `vnc`, `windows`, `wrapper_hostsfile`, `wrapper_java`, `wrapper_yum`, `xvfb`, `yum`, `yum-epel` 

Occasionally this may lead to a error in provisioning e.g. conflict between build-essential docker dependency that is processed on a windows guest as it were a mac.

### See also

* [yandex-qatools/chef-selenium](https://github.com/yandex-qatools/chef-selenium)
* [NERC-CEH/puppet-selenium](https://github.com/NERC-CEH/puppet-selenium)
* [jhoblitt/puppet-selenium](https://github.com/jhoblitt/puppet-selenium)

### Author
[Serguei Kouzmine](kouzmine_serguei@yahoo.com)
