#!/bin/sh

# this probably isn't necessary
# if already installed, unload lanchd
FILE=/Library/LaunchDaemons/com.gravitl.netclient.plist
if [[ -f "$FILE" ]]; then
  launchctl unload /Library/LaunchDaemons/com.gravitl.netclient.plist
  exit 0


