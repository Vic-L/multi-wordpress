#!/usr/bin/env bash

CONFIG="/dev/xvdf /multi_wordpress_volume ext4 defaults,nofail 0 0"

if [ ! -f '/etc/fstab.bak' ]
then
  sudo cp /etc/fstab /etc/fstab.bak
  echo "fstab backup created."
else
  echo "fstab backup file already exists."
fi

if [[ $(tail -1 /etc/fstab) != $CONFIG ]]
then
  echo $CONFIG | sudo tee -a /etc/fstab
  sudo mount -a
else
  echo "EBS volume automounted before. Nothing to do here."
fi