#!/bin/sh

installer='pmx-installer-latest.zip'
destination=~/.panamax
curl -O "http://download.panamax.io/installer/$installer"
unzip  -ou ${installer}  -d ${destination}
sudo ln -sf ~/.panamax/panamax /usr/local/bin/panamax
panamax init
#echo "Execute panamax and select to continue."

