name             'wrapper_maven'
maintainer       'Serguei Kouzmine'
maintainer_email 'koumine_serguei@yahoo.com'
description      'Installs/Configures Maven using cookbook wrapper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'
supports         'ubuntu', '>= 12.04'
supports         'centos'
depends	         'java' ,'>= 1.31'
depends	         'maven' ,'>= 5.1.0'
