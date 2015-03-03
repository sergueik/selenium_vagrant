@echo OFF 
cd %~dp0
set VAGRANT_HOME=%CD%
set VAGRANT_USE_PROXY=1
set PATH=%VAGRANT_HOME%\bin;%VAGRANT_HOME%\embedded\bin;%PATH%
REM This is settings that works for Ruby, but does not work with Vagrant:
set HTTP_PROXY=http://sergueik:Pe%%40rlF1sher%%3B@proxy.carnival.com:8080
REM May collide with a Vagrant  setting too
REM Could not resolve host: (nil); Host not found

goto :EOF
 

vagrant box add centos-6.5-x86 https://atlas.hashicorp.com/chef/boxes/centos-6.5-i386
https://atlas.hashicorp.com/chef/boxes/centos-6.5-i386
https://atlas.hashicorp.com/boxes/search?utf8=%E2%9C%93&sort=&provider=&q=centos+6.5

# http://stackoverflow.com/questions/27975541/vagrant-chef-error-in-provision-shared-folders-that-chef-requires-are-missin
http://www.vagrantbox.es/




==> default: Adding box 'hashicorp/precise64' (v0) for provider: virtualbox
    default: Downloading: http://files.vagrantup.com/precise64.box
    default: Progress: 0% (Rate: 0curl:/s, Estimated time remaining: --:--:--)
An error occurred while downloading the remote file. The error
message, if any, is reproduced below. Please fix this error and try
again.

Failed connect to files.vagrantup.com:80; No error