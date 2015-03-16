default['firebug']['firebug']['version'] = '2.0.5b1'
default['firebug']['firebug']['url'] = \
"https://getfirebug.com/releases/firebug/#{default['firebug']['firebug']['version'].gsub(/\.[^.]+?$/, '')}/firebug-#{default['firebug']['firebug']['version']}.xpi"
