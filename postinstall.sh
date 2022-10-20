#!/bin/sh
export PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin 
# symlink new directory contents so it's in $PATH
# sudo ln -s /usr/local/netclient/netclient /usr/local/bin
# sudo ln -s /usr/local/netclient/wg /usr/local/bin
# sudo ln -s /usr/local/netclient/wireguard-go /usr/local/bin
# Patch launchd so it works- this is to cope with the binary location changing from /etc to /usr/local... 
sudo sed -i '' 's|/etc/netclient/netclient|/usr/local/bin/netclient|g' /Library/LaunchDaemons/com.gravitl.netclient.launchd.plist 
# Load new launchd launchctl 
load -w /Library/LaunchDaemons/com.gravitl.netclient.plist &>/dev/null 
# Need to enable it so it launches at startup? 
sudo launchctl enable system/com.gravitl.netclient 
echo restarted patched launch daemon
