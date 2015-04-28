# Turn off firewall
chkconfig iptables off

# Provision update yum repositories
sudo yum -y update

# Provision new glibc
sudo yum -y install glibc.i686

# Provision misc tools
sudo yum install -y vim man-1.6f-32.el6 git-1.7.1-3.el6_4.1 wget-1.12-1.8.el6

# Provision Grab "Development Tools" for compiling software from sources
sudo yum -y groupinstall "Development Tools"

# Provision GNU screen
sudo yum -y install screen-4.0.3-16.el6

# Adding the EPEL
sudo yum -y install epel-release-6-8.noarch
