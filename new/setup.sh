#!/bin/bash



JQ='jq'
COOKBOOKS='jenkins' 'runit' 'dpkg_autostart' 'windows' 'powershell'  'packagecloud' 'yum-epel'
JQ=''
for cookbook in 'jenkins' 'runit' 'dpkg_autostart' 'windows' 'powershell'  'packagecloud' 'yum-epel'
do
  echo "Installing ${cookbook}"
  if [ ! -f "${cookbook}.tgz" ] ; then
    curl -L -k -o "${cookbook}.tgz" "https://supermarket.chef.io/cookbooks/${cookbook}/download/"
  fi
  >/dev/null pushd cookbooks
  tar xf "../${cookbook}.tgz"
  >/dev/null popd
done
# List module dependencies
for cookbook in 'jenkins' 'runit' 'dpkg_autostart' 'windows' 'powershell' 'packagecloud' 'yum-epel' ; do
  cat "cookbooks/${cookbook}/metadata.json" | $JQ /c/tools/jq-win64.exe '.dependencies | keys[]'

done
