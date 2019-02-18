name             'unix_sample'
maintainer       'Serguei Kouzmine'
maintainer_email 'koumine_serguei@yahoo.com'
description      'Installs/Configures sample Bash script to drain maven repo inside Jenkins when specified disk percent_used getting too high'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.4'

supports         'ubuntu', '>= 12.04'
supports         'centos'

depends	         'jenkins' ,'>= 6.2.0'
