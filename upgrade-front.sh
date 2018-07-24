#!/bin/bash

docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/front-1
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/front-2
docker-compose up -d front-1
docker-compose up -d front-2
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/front-1
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/front-2

docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/front-3
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/front-4
docker-compose up -d front-3
docker-compose up -d front-4
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/front-3
docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/front-4

# Make HAproxy reload the config file
# docker kill -s HUP emres-server_haproxy_1
