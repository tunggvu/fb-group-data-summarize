#!/bin/bash

# Always build the latest version of the application
docker build -t emres-server .

# Migrate database to the latest version
docker-compose run --rm app-1 bundle exec rake db:migrate

# Proceed to upgrade servers. The proxy will automatically pickup when the
# servers start
docker-compose up -d app-1
sleep 5
docker-compose up -d app-2
sleep 5
docker-compose up -d app-3

# Make HAproxy reload the config file
# docker kill -s HUP emres-server_haproxy_1
