#!/usr/bin/env bash

# in /multi_wordpress_volume/
cd /multi_wordpress_volume
docker swarm init
docker stack deploy -c docker-compose.yml multi_wordpress