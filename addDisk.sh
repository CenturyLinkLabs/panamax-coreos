#!/bin/sh

panamax pause
VBoxManage createhd --filename images.vdi --size 32768
VboxManage storagectl panamax-vm --name "IDE Controller" --add sata
VBoxManage storageattach panamax-vm --storagectl "IDE Controller" --port 1 --device 0 --type hdd --medium pmx_images.vdi
mkfs.btrfs /dev/sdb


VBoxManage storagectl panamax-vm --name "SATA Controller" --remove
VBoxManage storageattach panamax-vm --storagectl "IDE Controller" --port 1 --device 0 --type hdd --medium ''

drives=( `ls /dev/sd*` ); for i in "${drives[@]}"; do  if [[ "`df -k | grep $i`" == "" ]]; then imageDrive=$i; fi; done; echo $imageDrive
