#!/bin/sh

drives=( `ls /dev/sd*` ); for i in "${drives[@]}"; do  if [[ "`df -k | grep $i`" == "" ]]; then imageDrive=$i; fi; done;
echo "[Unit]
Name=var-lib-docker.mount
Description=Mount images.vdi to /var/lib/docker
Before=docker.service

[Mount]
What=$imageDrive
Where=/var/lib/docker
Type=btrfs

[Install]
WantedBy=multi-user.target" > var-lib-docker.mount
sudo cp var-lib-docker.mount /etc/systemd/system/

