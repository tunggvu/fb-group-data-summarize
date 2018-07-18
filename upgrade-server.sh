#!/bin/bash

# Migrate database to the latest version
docker-compose run --rm server-1 bundle exec rake db:migrate

# Proceed to upgrade servers. The proxy will automatically pickup when the
# servers start
docker-compose up -d server-1
sleep 5
docker-compose up -d server-2
sleep 5
docker-compose up -d server-3
sleep 5
docker-compose up -d server-4

# Make HAproxy reload the config file
docker kill -s HUP emres-server_haproxy_1
