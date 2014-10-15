#!/bin/sh

installer='panamax-latest.tar.gz'
destination=~/.panamax
curl -O "http://download.panamax.io/installer/$installer"
mkdir -p ${destination} && tar -C ${destination} -zxvf ${installer}
sudo ln -sf ~/.panamax/panamax /usr/local/bin/panamax
panamax init
#echo "Execute panamax and select to continue."
