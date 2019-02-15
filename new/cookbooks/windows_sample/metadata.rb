name 'windows_sample'
maintainer       'maintainer'
maintainer_email 'kouzmine_serguei@yahoo.com'
license          'All rights reserved'
description      'Installs/Configures sample clean up script to drain maven repo inside Jenkins when getting too big'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.2'
supports         'windows'

depends          'windows', '>= 5.2.3'
depends          'powershell', '>= 6.1.3'
