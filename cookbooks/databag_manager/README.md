`vnc` Cookbook
==========================

Use this cookbook to install and configure all the components that you need to set up a remote desktop connection to a server.  The default recipe in this cookbook installs the following components:

* VNC server - implements "Virtual Network Computing" allowing a remote computer to view the desktop of the computer on which the VNC server is running.
* Desktop environment - provides the graphical desktop environment with windows, icons, etc.
* Web browser - provides the ability to view HTML pages.

The cookbook creates a VNC server service and user account to under which the VNC server and desktop are run.  For answers to questions about this cookbook see the provided [FAQ](./FAQ.md).

The components used in the default recipe are [TightVNC](http://www.tightvnc.com/), [LXDE](http://lxde.org/) and [Firefox](http://www.mozilla.org/en-US/firefox/all/), which are all installed using the latest versions from the standard Ubuntu repository. These were chosen for the default recipe as a working set but others work equally well, for example [x11vnc](http://en.wikipedia.org/wiki/X11vnc) for the VNC server, [XFCE4](http://www.xfce.org/) for the desktop and [Chrome](www.google.com/chrome) for the browser.  You will need to modify the creation of the vncservice and xstartup scripts in the default recipe if you want to use different VNC server and desktop implementations.

Requirements
------------
 
## Chef

* Chef: 0.10.10+

## Cookbooks

No other cookbooks are required by this cookbook. 

## Platforms

The cookbook currently supports:

* Ubuntu 12.04 LTS x86-64

Attributes
----------
#### vnc::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['vnc']['geometry']</tt></td>
    <td>String</td>
    <td>Geometry of the desktop, specified as pixels horizontal x vertical.</td>
    <td><tt>1024x768</tt></td>
  </tr>
  <tr>
    <td><tt>['vnc']['account_username']</tt></td>
    <td>String</td>
    <td>Name of the user account to set up for use with the installed components. If the account does not exist, it will be created.</td>
    <td><tt>vncuser</tt></td>
  </tr>
</table>

Usage
-----
Include `vnc` in your node's `run_list` to install and set up all VNC and desktop components.
Once the recipe has been run on a node you will need to SSH to the node, log in as root and perform the following commands
to complete the configuration:

```
su - <insert user name here, default vncuser>
vncpasswd
<enter the password to be used for VNC connections and confirm it>
logout
service vncserver start
```

License and Authors
-------------------
Copyright 2013 IBM Corp. under the [Eclipse Public license](http://www.eclipse.org/legal/epl-v10.html).

The component installations referred to above are suggested by the Author and Contributors as a working set, however, other products are available which will provide similar functionality.  The Author and Contributors shall have no responsibility or liability in respect of the products that are installed by the EPL Chef script.   These products are not licensed by the Author and are subject to the terms and conditions imposed by their respective Licensors.

* Author:: Simon Holdsworth simon_holdsworth@uk.ibm.com

