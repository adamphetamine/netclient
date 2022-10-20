# netclient

This is an attempt to package netclient, wireguard-go and wireguard-tools into a single installer that runs on macOS. 

Requirements

Runs on macOS

'go' v1.18 or later installed to build wireguard and wireguard-tools

'jq' to parse json

Packages.app to build the installer package http://s.sudre.free.fr/Software/Packages/about.html

Here are the main files and what to do with them

netclient_pkg_builder.sh

This is the main script, which will pull down the components and make them ready to go into a package. It will then pass off the bits to Packages.app to make the package, then it calls notarise.sh to sign, notarise and staple the notarisation to the installer. Then it prints some checks in the terminal and opens the folder in Finder to show you the completed installer.

notarise.sh

As noted above, this will sign, notarise and staple the notarisation to the installer

custom.env

This is the file where you declare all the variables needed to build your installer

com.gravitl.netclient.plist

For the launch daemon, to be added to Packages.app project

netclient.entitlements

Entitlements file to allow for hardened runtime
