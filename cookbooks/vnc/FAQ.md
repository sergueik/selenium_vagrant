FAQ for the `vnc` cookbook
==========================================
##Questions:
[Can I run the `vnc` recipes on a machine that already has VNC installed?](#Q1)

[Can I run the `vnc` recipes using other VNC, desktop and browser implementations?](#Q2)

[Does this recipe create a secure vnc connection?](#Q3)
    
------------------------------------------
##Answers:
<a name="Q1">Can I run the `vnc` recipes on a machine that already has VNC installed?</a>

Yes, however the default recipe will replace any existing vnc server service with its own server startup, 
replace any existing xstartup script with its own, and start the LXDE desktop regarless of any existing
desktop installation.

<a name="Q2">Can I run the `vnc` recipes using other VNC, desktop and browser implementations?</a>

This will require modification of the recipe, to install the required packages, and in the case of a
different VNC or desktop package the vncserver script and xstartup scripts might need to be modified 
accordingly.

<a name="Q3">Does this recipe create a secure vnc connection?</a>

No.  In order to secure the vnc connection you need to enable your vnc client to connect to the server
over SSH.  A web search for "VNC SSH tunnel" should provide information on how to do this.
