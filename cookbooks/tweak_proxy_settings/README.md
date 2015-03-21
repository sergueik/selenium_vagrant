NOTE: To continue using the box created with the different  proxy settings update the files
and reload the box, to change the user  - a reboot may be sufficient 

 /etc/environment
 /etc/profile.d/proxy.sh
 /etc/resolv.conf
 for redhat based
 need a sed command 
 /etc/yum.conf 
 for debian based TBD

/etc/environment:HTTP_PROXY=http://[user:password@]host:port
/etc/environment:HTTPS_PROXY=http://[user:password@]host:port
/etc/environment:http_proxy=http://[user:password@]host:port
/etc/environment:https_proxy=http://[user:password@]host:port
/etc/profile.d/proxy.sh:export HTTP_PROXY=http://[user:password@]host:port
/etc/profile.d/proxy.sh:export http_proxy=http://[user:password@]host:port
/etc/profile.d/proxy.sh:export HTTPS_PROXY=http://[user:password@]host:port
/etc/profile.d/proxy.sh:export https_proxy=http://[user:password@]host:port
/etc/resolv.conf:search carnival.com
/etc/resolv.conf:search cchq.mia.wayport.net
/etc/resolv.conf:nameserver 10.0.2.3
/etc/resolv.conf:nameserver 4.4.4.4
/etc/yum.conf:proxy=http://proxy.carnival.com:8080


modern-ie-vagrant-boxes/