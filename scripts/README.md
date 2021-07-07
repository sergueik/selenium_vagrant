### Running Processes
* display (launched by `/etc/init.d/Xvfb` script, can also be launched directly, or via systemd ):
```sh
/usr/bin/Xvfb :99 +extension RANDR -screen 0 1024x768x24 -fbdir /var/run -ac
Xvfb :1000 -ac
```
* node:
```sh
java -XX:MaxPermSize=256M -Xmn128M -Xms256M -Xmx256M -Dwebdriver.chrome.driver=/home/vagrant/chromedriver \
-jar /home/vagrant/selenium-server-standalone.jar -role node -host 127.0.0.1 -port 5555 \
-hub http://127.0.0.1:4444/hub/register -nodeConfig /home/vagrant/node.json \
-browserTimeout 12000 -timeout 12000
```
* hub (default command shown, customizations possible):
```sh
java -jar selenium-server-standalone.jar -role hub
```
the `:DISPLAY` information is passed via environment:
```sh
xargs -0 -L1 -a  /proc/6477/environ| grep DISPLAY
```
```sh
DISPLAY_PORT=1000
DISPLAY=:1000
```
the TCP ports of node and hub are passed via arguments andalso via `node.json`  and `hub.json` (the latter is currentky unused, and may need update).
### 