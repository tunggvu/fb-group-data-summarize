#!/bin/bash

# Migrate database to the latest version
docker-compose run --rm server-1 bundle exec rake db:migrate

# Set server-1 and server-2 down
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/server-1
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/server-2
docker-compose up -d server-1
docker-compose up -d server-2
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/server-1
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/server-2

docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/server-3
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/server-4
docker-compose up -d server-3
docker-compose up -d server-4
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/server-3
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/server-4

# Make HAproxy reload the config file
# docker kill -s HUP emres-server_haproxy_1
