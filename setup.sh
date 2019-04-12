#!/bin/bash

for cookbook in chrome chef_handler dmg yum apt windows java hostsfile vnc x-windows gnome ark build-essential seven_zip mingw maven gradle; do 
  if [ ! -f "${cookbook}.tgz" ] ; then
    wget -O "${cookbook}.tgz" "https://supermarket.chef.io/cookbooks/${cookbook}/download/"
  fi
  pushd cookbooks
  tar xvf "../${cookbook}.tgz"
  popd
done

# keep individual cookbook dodnwload instructions
if [ ! -f 'chrome.tgz' ] ; then
  wget -O chrome.tgz https://supermarket.chef.io/cookbooks/chrome/download/
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
if [ ! -f 'hostsfile.tgz' ] ; then
  wget -O hostfile.tgz https://supermarket.chef.io/cookbooks/hostsfile/download
fi
if [ ! -f 'vnc.tgz' ] ; then
  wget -O vnc.tgz https://supermarket.chef.io/cookbooks/vnc/download
fi
if [ ! -f 'x-windows.tgz' ] ; then
  wget -O x-windows.tgz https://supermarket.chef.io/cookbooks/x-windows/download/
fi
if [ ! -f 'gnome.tgz' ] ; then
  wget -O gnome.tgz https://supermarket.chef.io/cookbooks/gnome/download/
fi
if [ ! -f 'ark.tgz' ] ; then
  wget -O ark.tgz https://supermarket.chef.io/cookbooks/ark/download/
fi
if [ ! -f 'build-essential.tgz' ] ; then
  wget -O build-essential.tgz https://supermarket.chef.io/cookbooks/build-essential/download/
fi
if [ ! -f 'seven_zip.tgz' ] ; then
  wget -O seven_zip.tgz https://supermarket.chef.io/cookbooks/seven_zip/download/
fi
if [ ! -f 'mingw.tgz' ] ; then
  wget -O mingw.tgz https://supermarket.chef.io/cookbooks/mingw/download/
fi
if [ ! -f 'maven.tgz' ] ; then
  wget -O maven.tgz https://supermarket.chef.io/cookbooks/maven/download/
fi
if [ ! -f 'gradle.tgz' ] ; then
  wget -O gradle.tgz https://supermarket.chef.io/cookbooks/gradle/download/
fi

pushd cookbooks
tar xzf ../chrome.tgz 
tar xzf ../apt.tgz 
tar xzf ../yum.tgz 
tar xzf ../windows.tgz 
tar xzf ../dmg.tgz 
tar xzf ../chef_handler.tgz 
tar xzf ../hostsfile.tgz 
tar xzf ../vnc.tgz 
tar xzf ../x-windows.tgz 
tar xzf ../gnome.tgz 
tar xzf ../build-essential.tgz 
tar xzf ../seven_zip.tgz 
tar xzf ../mingw.tgz 
tar xzf ../maven.tgz 
tar xzf ../gradle.tgz 
popd


