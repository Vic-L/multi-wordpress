#!/usr/bin/env bash

if ! test -f docker-compose.production.yml
then
  echo "docker-compose.production.yml file is not present. Make sure you run \`make setup\` and go through the instructions before you deploy."
else
  cd /multi_wordpress_volume
  docker swarm init
  docker stack deploy -c docker-compose.base.yml -c docker-compose.production.yml multi_wordpress
fi
