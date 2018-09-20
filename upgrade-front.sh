#!/bin/bash

show_usage() {
  echo "Run "./upgrade-front.sh" to upgrade staging front-end"
  echo "Run "./upgrade-front.sh production" to upgrade production front-end"
}

if [ $# -eq 0 ]
then
  # Upgrade *STAGING* fronts
  docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-front/front-1
  docker-compose up -d front-1
  sleep 10
  docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-front/front-1

  docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-front/front-2
  docker-compose up -d front-2
  sleep 10
  docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-front/front-2

else
  case $1 in
    "production")
      # Upgrade *PRODUCTION* fronts
      docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-front/front-3
      docker-compose up -d front-3
      sleep 10
      docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-front/front-3

      docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-front/front-4
      docker-compose up -d front-4
      sleep 10
      docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-front/front-4
    ;;
    "-h")
      show_usage
      ;;
    *)
      show_usage
      ;;
  esac
fi


# Make HAproxy reload the config file
# docker kill -s HUP emres-server_haproxy_1
