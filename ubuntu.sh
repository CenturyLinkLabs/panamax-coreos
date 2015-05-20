#!/bin/bash

installer='panamax-0.0.1.tar.gz'
destination=~/.panamax
curl -O "http://download.panamax.io/installer/$installer"
mkdir -p ${destination} && tar -C ${destination} -zxvf ${installer}
if [[ "`lsb_release -r | grep 15.0[0-9]*`" != "" ]]; then
 read -p "Do you want to install Panamax locally [Y/n]: " localInstall
 if [[ "$localInstall" == "y" || "$localInstall" == "Y" || "$localInstall" == "" ]]; then
    sed -i s/desktop/desktop_ubuntu15.sh/g  ~/.panamax/panamax
 fi
fi
sudo ln -sf ~/.panamax/panamax /usr/local/bin/panamax
curl -O http://download.panamax.io/panamaxcli/panamaxcli-linux
sudo mv panamaxcli-linux /usr/local/bin/pmxcli && chmod 755 /usr/local/bin/pmxcli
#echo "Execute panamax and select to continue."
