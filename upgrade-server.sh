#!/bin/bash

show_usage() {
  echo "Run "./upgrade-server.sh" to upgrade staging server"
  echo "Run "./upgrade-server.sh production" to upgrade production server"
}

if [ $# -eq 0 ]
then
  echo "staging"
  # Migrate *STAGING* database to the latest version
  docker-compose run --rm server-1 bundle exec rake db:migrate

  # Upgrade *STAGING* servers
  docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/server-1
  docker-compose up -d server-1
  sleep 10
  docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/server-1

  docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/server-2
  docker-compose up -d server-2
  sleep 10
  docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/server-2

else
  case $1 in
    "production")
      echo "production"
      # Migrate *PRODUCTION* database to the latest version
      docker-compose run --rm server-3 bundle exec rake db:migrate

      # Upgrade *PRODUCTION* servers
      docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/server-3
      docker-compose up -d server-3
      sleep 10
      docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/server-3

      docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server down emres-server/server-4
      docker-compose up -d server-4
      sleep 10
      docker exec $(docker container ls -q -f NAME=haproxy) haproxy_set_server up emres-server/server-4
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
