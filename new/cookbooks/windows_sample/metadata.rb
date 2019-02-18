name             'windows_sample'
maintainer       'maintainer'
maintainer_email 'kouzmine_serguei@yahoo.com'
license          'All rights reserved'
description      'Installs/Configures sample Powrshell script to drain maven repo inside Jenkins when specified drive freespace getting too low'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.2'
supports         'windows'

depends          'windows', '>= 5.2.3'
depends          'powershell', '>= 6.1.3'
depends	         'jenkins' ,'>= 6.2.0'
