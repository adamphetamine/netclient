#!/bin/sh

# upgrade netclient on linux clients

# Find the current netclient version
netclient_tag=$(curl -sL https://api.github.com/repos/gravitl/netmaker/releases/latest | jq -r ".tag_name")
echo -----------------------------------------
echo current version of netclient is $netclient_tag
echo -----------------------------------------
read -p  "Do you wish to install this version?" -n 1 -r
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    exit 1
fi

# stop service
systemctl stop netclient.service

# move to netclient directory
cd /etc/netclient

# if there's an old backup, remove it
FILE=/etc/netclient.bak
if [[ -f "$FILE" ]]; then
  rm $FILE
  exit 0

# back up current binary
mv netclient netclient.bak

# download the new version into correct directory
curl -L https://github.com/gravitl/netmaker/releases/download/$netclient_tag/netclient --output /etc/netclient/netclient

# make new binary executable
chmod a+x netclient

# restart service
systemctl start netclient.service

# get new config
netclient pull

exit 0
