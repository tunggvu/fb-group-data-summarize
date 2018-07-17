#!/bin/bash

# Proceed to upgrade servers. The proxy will automatically pickup when the
# fronts start
docker-compose up -d front-1
sleep 5
docker-compose up -d front-2
sleep 5
docker-compose up -d front-3
sleep 5
docker-compose up -d front-4

# Make HAproxy reload the config file
docker kill -s HUP emres-server_haproxy_1
