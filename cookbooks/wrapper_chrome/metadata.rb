name             'wrapper_chrome'
maintainer       'Serguei Kouzmine'
maintainer_email 'koumine_serguei@yahoo.com'
description      'Installs/Configures chrome using cookbook wrapper'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.1'
# https://supermarket.chef.io/cookbooks/chrome/download
depends	         'chrome' ,'>= 1.1.1'
