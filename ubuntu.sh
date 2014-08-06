#!/bin/sh

installer='pmx-installer-latest.zip'
destination=~/.panamax
curl -O "http://download.panamax.io/installer/$installer"
unzip  -ou ${installer}  -d ${destination}
cp ${destination}/panamax /usr/bin
panamax
#echo "Execute panamax and select to continue."

