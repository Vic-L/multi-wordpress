#!/usr/bin/env bash

AUTOMOUNT_CONFIG="/dev/xvdf /multi_wordpress_volume ext4 defaults,nofail 0 0"
SWAP_CONFIG="/swapfile swap swap defaults 0 0"

if [ ! -f '/etc/fstab.bak' ]
then
  sudo cp /etc/fstab /etc/fstab.bak
  echo "fstab backup created."
else
  echo "fstab backup file already exists."
fi

if [[ $(tail -1 /etc/fstab) != $AUTOMOUNT_CONFIG ]]
then
  echo $AUTOMOUNT_CONFIG | sudo tee -a /etc/fstab
  sudo mount -a
else
  echo "EBS volume automount added to /etc/fstab before. Nothing to do here."
fi

if [[ $(tail -1 /etc/fstab) != $SWAP_CONFIG ]]
then
  echo $SWAP_CONFIG | sudo tee -a /etc/fstab
  sudo mount -a
else
  echo "Swap added to /etc/fstab before. Nothing to do here."
fi