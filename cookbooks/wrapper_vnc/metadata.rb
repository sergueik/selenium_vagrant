name             'wrapper_vnc'
maintainer       'Serguei Kouzmine'
maintainer_email 'koumine_serguei@yahoo.com'
description      'Installs/configures vnc to run under specific user'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'
# https://supermarket.chef.io/cookbooks/vnc
depends	         'vnc' ,'>= 1.0.0'
