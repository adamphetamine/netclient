#!/bin/sh

# version 2 built 19 October 2022
# build folder is now /Users/Shared/netclient/packages/binaries

# our variables are in this file
source /Users/Shared/netclient/custom.env

echo --------------------------------
echo |  NetMaker Maker |
echo --------------------------------
# Exit script if anything fails. This can be commented out when working properly
set -e

# ok starting out let's clear the build folders
echo --------------------------------
echo clear the build folders
echo --------------------------------
rm -rf wireguard-go
rm -rf wireguard-tools
rm -rf packages/binaries/*
rm -rf packages/build/*

echo --------------------------------
echo Download and build wireguard-go
echo --------------------------------

# requires go v1.18 or better installed on your machine
# builds wireguard-go that is compatible with linux, macOS, Windows, FreeBSD, OpenBSD but see readme for limitations
git clone https://git.zx2c4.com/wireguard-go
cd wireguard-go
make

echo --------------------------------
echo Download and build wireguard-tools
echo --------------------------------
# requires go v1.18 or better installed on your machine
# netmaker people claimed that we don't need the tools any longer, but their installer still has it, and does not appear to work without it
cd ..
git clone https://git.zx2c4.com/wireguard-tools
cd wireguard-tools/src
make

echo --------------------------------
echo move wireguard-tools and wg and make executable
echo --------------------------------
mv $BASEDIR/wireguard-go/wireguard-go $BASEDIR/packages/binaries/wireguard-go
mv $BASEDIR/wireguard-tools/src/wg $BASEDIR/packages/binaries/wg
cd $BASEDIR/packages/binaries

chmod +x wg && chmod +x wireguard-go

# now let's remove any xattr detritus it has picked up so it can be codesigned
xattr -cr wg
xattr -cr wireguard-go

echo remove xattr is finished

echo --------------------------------
echo codesign wireguard-tools and wg
echo --------------------------------
# this is not the main binary, and according to Apple, thus does not need entitlements file attached- but Apple rejected the .pkg because wg did not have hardened runtime
codesign --force --options=runtime --sign "$Developer_ID_Application" --timestamp ./wg
if  [ $? -eq 0 ]
then
     echo signing wg Package Succeeded
else
     echo signing wg Package Failed
fi

echo we are in $PWD
# codesign wireguard-go
codesign --force --options=runtime --sign "$Developer_ID_Application" --timestamp ./wireguard-go
if  [ $? -eq 0 ]
then
     echo signing wireguard-go Package Succeeded
else
     echo signing wireguard-go Package Failed
fi

# back into a temp folder to get the binary
cd $BASEDIR/packages/binaries

echo --------------------------------
echo Download Netclient
echo --------------------------------
echo Downloading to $PWD

# Find the current netclient version
netclient_tag=$(curl -sL https://api.github.com/repos/gravitl/netmaker/releases/latest | jq -r ".tag_name")
echo current version of netclient is $netclient_tag

# strip the leading 'v' from version number
raw_vers="${netclient_tag:1}"
echo so the raw version number is $raw_vers

# this bit currently not working- in future you will choose Intel or Apple Silicon for the .pkg
# Build_Choice='Build for which architecture? '
# arch=("Intel" "Apple Silicon" "Choice 3" "Quit")
# select fav in "${arch[@]}"; do
#     case $fav in
#         "Intel")
#             echo "You selected $fav architecture!"
#             # need to exit the loop here and continue the script
#             ;;
#         "Apple Silicon")
#             echo "You selected $fav architecture!"
# 	    # optionally call a function or run some code here
#             ;;
#         "Choice 3")
#             echo "According to NationalTacoDay.com, Americans are eating 4.5 billion $fav each year."
# 	    # optionally call a function or run some code here
# 	    break
#             ;;
# 	"Quit")
# 	    echo "User requested exit"
# 	    exit
# 	    ;;
#         *) echo "invalid option $REPLY";;
#     esac
# done

wget  https://github.com/gravitl/netmaker/releases/download/$netclient_tag/netclient-darwin

if  [ $? -eq 0 ]
then
      echo Downloading netclient Package Succeeded
       else
      echo Downloading netclient Package Failed
 fi

echo --------------------------------
echo Rename netclient-darwin to netclient and make executable
echo --------------------------------
mv netclient-darwin $BASEDIR/packages/binaries/netclient

cd $BASEDIR/packages/binaries
chmod +x netclient

# now let's remove any xattr detritus it has picked up so it can be codesigned
xattr -cr netclient

# change to directory for adding entitlements
cd $BASEDIR/packages/binaries

echo --------------------------------
echo  Codesign netclient
echo --------------------------------
# make sure entitlements file is in the folder

wget https://raw.githubusercontent.com/adamphetamine/netclient/main/netclient.entitlements
codesign --deep --force --options=runtime --entitlements netclient.entitlements --sign "$Developer_ID_Application" --timestamp ./netclient
# codesign --force --options=runtime --sign "$Developer_ID_Application" --timestamp ./wireguard-go
if  [ $? -eq 0 ]
then
     echo signing netclient Package Succeeded
else
     echo signing netclient Package Failed
fi

# now we can remove the entitlements file because it is not needed anymore
rm netclient.entitlements

# download postinstall, .plist and pre-install scripts
echo ---------------------------------------
echo Download Post-Install and .plist files
echo ---------------------------------------

wget https://raw.githubusercontent.com/adamphetamine/netclient/main/postinstall.sh 
chmod +x $BASEDIR/packages/binaries/postinstall.sh

wget https://raw.githubusercontent.com/adamphetamine/netclient/main/com.gravitl.netclient.plist


# use pre-built packages.app template to build the .pkg
echo --------------------------------
echo get Packages.app to build the .pkg
echo --------------------------------

/usr/local/bin/packagesbuild --verbose --project $BASEDIR/packages/netclient_packages.pkgproj VERSION="$raw_vers"
if  [ $? -eq 0 ]
then
     echo building netclient installer Succeeded
else
     echo building netclient installer Failed
fi

# Assuming the build was successful, we can pass off to the notarise script to sign and notarise the installer
echo -----------------------------------------------------------
echo call notarise script to upload, notarise and staple the .pkg
echo -----------------------------------------------------------
$BASEDIR/packages/Notarise.sh
if  [ $? -eq 0 ]
then
     echo notarising netclient installer Succeeded
else
     echo notarising netclient installer Failed
fi
exit 
