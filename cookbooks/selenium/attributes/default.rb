default['selenium']['selenium']['version'] = '2.44.0'
default['selenium']['firefox']['lang'] = 'en-US'
default['selenium']['selenium']['url'] = \
"http://selenium-release.storage.googleapis.com/#{default['selenium']['selenium']['version'].gsub(/\.\d+$/, '')}/selenium-server-standalone-#{default['selenium']['selenium']['version']}.jar"
default['selenium']['firefox']['version'] = '35.0.1'
default['selenium']['firefox']['arch'] = kernel['machine'] =~ /x86_64/ ? 'x86_64' : 'i686'
default['selenium']['firefox']['releases_url'] = 'https://download-installer.cdn.mozilla.net/pub/firefox/releases'
default['selenium']['firefox']['url'] = \
"#{default['selenium']['firefox']['releases_url']}/#{default['selenium']['firefox']['version']}/linux-#{default['selenium']['firefox']['arch']}/#{default['selenium']['firefox']['lang']}/firefox-#{default['selenium']['firefox']['version']}.tar.bz2"


default['selenium']['chrome_driver']['version'] = '2.16'
default['selenium']['chrome_driver']['releases_url'] = 'http://chromedriver.storage.googleapis.com'
default['selenium']['chrome_driver']['arch'] = kernel['machine'] =~ /x86_64/ ? '64' : '32'
default['selenium']['chrome_driver']['url'] = \
"#{default['selenium']['chrome_driver']['releases_url']}/#{default['selenium']['chrome_driver']['version']}/chromedriver_linux#{default['selenium']['chrome_driver']['arch']}.zip"
