name             'wrapper_hostsfile'
maintainer       'Serguei Kouzmine'
maintainer_email 'kouzmine_serguei@yahoo.com'
description      'Installs/configures/runs hosfile cookbook using cookbook wrapper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'
supports         'ubuntu', '>= 12.04'
depends	         'hostsfile'


# https://github.com/customink-webops/hostsfile