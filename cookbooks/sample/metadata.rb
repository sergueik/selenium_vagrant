name 'sample'
maintainer       "maintainer"
maintainer_email "skouzmine@carnival.com"
license          "All rights reserved"
description      "Installs/Configures sample"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"
supports         "windows"

depends          "windows", ">= 1.2.8"
depends          "powershell"
