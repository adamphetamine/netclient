#!/bin/sh

# unload lanchd
launchctl unload /Library/LaunchDaemons/com.gravitl.netclient.plist

# remove launchd
rm -f /Library/LaunchDaemons/com.gravitl.netclient.plist

# remove old bits from Servicemax install
rm /usr/local/bin/netclient
rm /usr/local/bin/wg
rm /usr/local/bin/wireguard-go

# remove old bits from new location
rm /usr/sbin/netclient
rm /usr/sbin/wg

# remove receipts
rm /private/var/db/receipts/com.gravitl.pkg.NetclientWireguard.bom
rm /private/var/db/receipts/com.gravitl.pkg.NetclientWireguard.plist

# remove new name receipts
rm /private/var/db/receipts/com.gravitl.pkg.netclient.bom
rm /private/var/db/receipts/com.gravitl.pkg.netclient.plist

# remove bits from the Netmaker standard install that doesn't work on macOS
rm -rf /private/etc/netclient
