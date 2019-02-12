name 'windows_sample'
maintainer       "maintainer"
maintainer_email "kouzmine_serguei@yahoo.com"
license          "All rights reserved"
description      "Installs/Configures sample clean up script to drain maven repo inside Jenkins when getting too big"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"
supports         "windows"

depends          "windows", ">= 1.2.8"
depends          "powershell"
