name             'unix_sample'
maintainer       'Serguei Kouzmine'
maintainer_email 'koumine_serguei@yahoo.com'
description      "Installs/Configures sample clean up script to drain maven repo inside Jenkins when getting too big"
description      'Installs/Configures chrome using cookbook wrapper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'
# https://supermarket.chef.io/cookbooks/chrome/download
supports         'ubuntu', '>= 12.04'
supports         'centos'
# TODO: to use maven itself to purge
# depends	         'java' ,'>= 1.31'
