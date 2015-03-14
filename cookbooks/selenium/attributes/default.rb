default['selenium']['selenium']['version'] = '2.44.0'
default['selenium']['selenium']['url'] = \
"http://selenium-release.storage.googleapis.com/#{default['selenium']['selenium']['version'].gsub(/\.\d+$/, '')}/selenium-server-standalone-#{default['selenium']['selenium']['version']}.jar"
default['selenium']['firefox']['version'] = '35.0.1'
default['selenium']['firefox']['url'] = \
"https://download-installer.cdn.mozilla.net/pub/firefox/releases/#{default['selenium']['firefox']['version']}/linux-x86_64/en-US/firefox-#{default['selenium']['firefox']['version']}.tar.bz2"

