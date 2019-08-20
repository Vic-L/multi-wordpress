#!/usr/bin/env bash

cd /multi_wordpress_volume
GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ssh_key" git pull origin master