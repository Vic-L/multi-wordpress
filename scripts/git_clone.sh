#!/usr/bin/env bash

echo Getting \"ssh_key\" from $1
aws s3 cp s3://$1/ssh_key /multi_wordpress_volume/ssh_key
chmod 400 /multi_wordpress_volume/ssh_key

echo Cloning repository from $2
# with reference to https://stackoverflow.com/a/43287779/2667545
cd /multi_wordpress_volume
git init
git remote add origin $2
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ssh_key" git fetch
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ssh_key" git checkout -t origin/master -f