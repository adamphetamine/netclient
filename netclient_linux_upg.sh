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
echo exited user input

# stop service
systemctl stop netclient.service
echo stopped netclient

# move to netclient directory
cd /sbin
echo moved to netclient directory

# if there's an old backup, remove it
FILE=/sbin/netclient.bak
if [[ -f "$FILE" ]]; then
  rm $FILE
fi
echo finished backup removal

# back up current binary
mv netclient netclient.bak
echo renamed netclient backup

# download the new version into correct directory
curl -L https://github.com/gravitl/netmaker/releases/download/$netclient_tag/netclient --output /sbin/netclient
echo downloaded new netclient

# make new binary executable
chmod 755 netclient
echo made executable

# restart service
systemctl start netclient.service
echo restarted service

# get new config
sudo netclient pull
echo completed netclient pull

exit 0
