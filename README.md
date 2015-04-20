# Introduction

Vagrant and Chef resources for setting up a box in Virtual Box running Java, Selenium, Spoon.Net, IE, Firefox, Phantom JS, and Chrome from Linux environment



## Environment 
Based on the `BOX_NAME` environment the following guest is created 

 - ubuntu32 
      base box with xvfb, xvnc, java runtime , selenium, firefox
 - ubuntu64
      base box with xvfb, xvnc, java runtime , selenium, firefox
 - centos65
      base box with docker, java runtime 
 - windows7
      base box with spoon, few spoon images  for selenium-grid and ie,9,10,11


## Open Items 
There is work in progress on adding chrome recipes to ubuntu, testing on centos, better error detection on windows7, especially  with spoon.Net layer
