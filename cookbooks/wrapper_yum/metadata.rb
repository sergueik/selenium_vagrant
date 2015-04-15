name             'wrapper_yum'
maintainer       'Serguei Kouzmine'
maintainer_email 'koumine_serguei@yahoo.com'
description      'Installs/Configures custom Yum repository'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'
supports         'centos'
depends	         'yum' ,'>= 3.0.0'
