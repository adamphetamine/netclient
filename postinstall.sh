#!/bin/sh
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin 
# Patch launchd so it works- this is to cope with the binary location changing from /etc to /usr/local... 
sudo sed -i '' 's|/etc/netclient/netclient|/usr/local/netclient/netclient|g' /Library/LaunchDaemons/com.gravitl.netclient.plist 
# Load new launchd launchctl 
load -w /Library/LaunchDaemons/com.gravitl.netclient.plist &>/dev/null 
# Need to enable it so it launches at startup? 
sudo launchctl enable system/com.gravitl.netclient 
echo restarted patched launch daemon
