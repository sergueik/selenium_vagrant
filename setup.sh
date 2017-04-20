#!/bin/bash
for cookbook in 'chrome' 'chef_handler' 'dmg' 'yum' 'apt' 'windows' 'java'  ; do 
if [ ! -f "${cookbook}.tgz" ] ; then
wget -O "${cookbook}.tgz" "https://supermarket.chef.io/cookbooks/${cookbook}/download/"
fi
pushd cookbooks
tar xvf "../${cookbook}.tgz"
popd
done
if [ ! -f 'chrome.tgz' ] ; then
wget -O chrome.tgz  https://supermarket.chef.io/cookbooks/chrome/download/
fi
if [ ! -f 'chef_handler.tgz' ] ; then
wget -O chef_handler.tgz https://supermarket.chef.io/cookbooks/chef_handler/download
fi
if [ ! -f 'dmg.tgz' ] ; then
  wget -O dmg.tgz https://supermarket.chef.io/cookbooks/dmg/download
fi 
if [ ! -f 'yum.tgz' ] ; then
wget -O yum.tgz https://supermarket.chef.io/cookbooks/yum/download 
fi
if [ ! -f 'apt.tgz' ] ; then
wget -O apt.tgz https://supermarket.chef.io/cookbooks/apt/download
fi
if [ ! -f 'windows.tgz' ] ; then
wget -O windows.tgz https://supermarket.chef.io/cookbooks/windows/download
fi
pushd cookbooks
tar xzf ../chrome.tgz 
tar xzf ../apt.tgz 
tar xzf ../yum.tgz 
tar xzf ../windows.tgz 
tar xzf ../dmg.tgz 
tar xzf ../chef_handler.tgz 
popd


