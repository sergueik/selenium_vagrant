name             'example'
maintainer       'Serguei Kouzmine'
maintainer_email 'koumine_serguei@yahoo.com'
description      'Installs/Configures sample Bash script to drain maven repo inside Jenkins when specified disk percent_used getting too high'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.4'

supports         'ubuntu', '>= 12.04'
supports         'centos'
supports         'windows'
# on Windows host still need to comment 'windows' and 'powershell' dependencies
#  linux: Recipe Compile Error in /var/chef/cache/cookbooks/powershell/libraries/powershell_module_provider.rb
# ==> linux: ================================================================================
# ==> linux: ArgumentError
# ==> linux: -------------
# ==> linux:
# ==> linux: unknown keyword: on_platforms
depends          'windows', '>= 5.2.3'
depends          'powershell', '>= 6.1.3'
depends	         'jenkins' ,'>= 6.2.0'
