#!/usr/bin/env bash

sudo yum -y update
sudo yum -y install docker git

# with reference to https://devopscube.com/mount-ebs-volume-ec2-instance/
if [[ $(sudo file -s /dev/xvdf) == "/dev/xvdf: data" ]]
then
  echo "EBS volume mounted on /dev/xvdf is empty. Formatting to ext4 format now..."
  sudo mkfs -t ext4 /dev/xvdf
else
  echo "EBS volume already contains content. Nothing to do here."
fi

echo "Creating /multi_wordpress_volume, changing permissions and mounting EBS volume"
sudo mkdir -p /multi_wordpress_volume
sudo chmod -R 775 /multi_wordpress_volume
sudo chown -R $(whoami) /multi_wordpress_volume
sudo chgrp -R $(whoami) /multi_wordpress_volume
sudo mount /dev/xvdf /multi_wordpress_volume/

echo "Creating volumes required for app"
mkdir -p /multi_wordpress_volume/db1
mkdir -p /multi_wordpress_volume/db2
mkdir -p /multi_wordpress_volume/wp1
mkdir -p /multi_wordpress_volume/wp2
mkdir -p /multi_wordpress_volume/logs