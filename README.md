# selenium_vagrant
Vagrant and Chef resources for Selenium Firefox, Phantom JS, and Chrome 

# selenium Vagrant and Chef resources for Selenium Firefox, Phantom JS, and Chrome 


in windows environment
install Vagrant 1.7.2 
install ruby 2.0.x
install chef 
to e.g. c:\vagrant
merge the contents of the c:\vagrant directory with the workspace 

set up paths

call vagrant up

only if you had a yesterday work  that contains incompatible code branches 
stop vagrant
call vagrant halt
remove previous run 
del /s/q .vagrant\machines\default\virtualbox\synced_folders
call vagrant reload 
call vagrant provision

> Shared folders that Chef requires are missing on the virtual machine.
> This is usually due to configuration changing after already booting the
> machine. The fix is to run a `vagrant reload` so that the proper shared

Install Git bash 
connect  to VM
ssh -p 2222 vagrant@127.0.0.1

vagrant@chef-book:~$ service --status-all 2>& 1|  egrep '(Xvfb|selenium_)'
 [ ? ]  Xvfb
 [ + ]  selenium_hub
 [ + ]  selenium_node

sudo sh -c  "cat /dev/null > /var/log/syslog"
Process check
ps ax | grep jav[a]
Port check

export DISPLAY_PORT=99
netstat -npl | grep STREAM  |grep $DISPLAY_PORT| awk '{print $9}'|head -1 | sed 's/\/.*$//'
 -  it will say 
(No info could be read for "-p": geteuid()=1000 but you should be root.)

and you run
sudo !!
Lock check

cat  /tmp/.X${DISPLAY_PORT}-lock

you will see the same PID 

netstat -npl | grep tcp | grep $NODE_PORT | awk '{print $7}'| grep '/java'|head -1 | sed 's/\/.*$//'


You wills ee the same PID as ps 
