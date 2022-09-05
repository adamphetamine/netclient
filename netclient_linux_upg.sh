#!/bin/sh

# upgrade netclient on linux clients

# stop service
systemctl stop netclient.service

# move to netclient directory
cd /etc/netclient

# back up old binary
mv netclient netclient.bak

# remember to update to correct version number in next line
curl -L https://github.com/gravitl/netmaker/releases/download/v0.15.0/netclient --output /etc/netclient/netclient

# make new binary executable
chmod a+x netclient

# restart service
systemctl start netclient.service


# get new config
netclient pull

exit 0
