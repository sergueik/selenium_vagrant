#!/bin/bash

# NOTE: the OS env. var is already taken
OPERATING_SYSTEM='windows'
if [[ "$OS" != 'Windows_NT' ]]
then
  OPERATING_SYSTEM='linux'
fi
  echo "Running under ${OPERATING_SYSTEM}"
if [ "${OPERATING_SYSTEM}" = 'linux'  ] ; then
  JQ='jq'
else
  JQ='/c/tools/jq-win64.exe'
fi
# ubuntu  test only
COOKBOOKS='jenkins runit dpkg_autostart packagecloud yum-epeli java homebrew'
# ubuntu and windows tests
COOKBOOKS='jenkins runit dpkg_autostart windows ms_dotnet powershell packagecloud yum-epel java homebrew'
which $JQ > /dev/null
if [ ! $? ] ; then
  sudo apt-get -qqy install jq curl
fi
for cookbook in $COOKBOOKS
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
for cookbook in $COOKBOOKS
do
  cat "cookbooks/${cookbook}/metadata.json" | $JQ '.dependencies | keys[]'
done
