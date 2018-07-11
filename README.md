![CircleCI](https://circleci.com/gh/framgia/emres-server/tree/master.svg?style=svg&circle-token=cebf88f3f6124e9a2d0afa48690245c9de7b8499)

# README

Create Data:
* rake db:seed_fu

## Build Docker Image

#### Create data folder for postgres
`mkdir -p /data/emres-server/`

#### Create `application.yml`
`cp config/application.yml.sample config/application.yml`

**You should update the environment variable inside this file to make `whenever`'s
job work correctly**

#### Build the latest version
`docker build -t emres-server --rm .`

#### Initialize Docker Swarm
`docker swarm init`

#### Set SECRET_KEY_BASE
`rails secret | docker secret create rails_secret -`

#### Deploy emres-server with postgres
`docker stack deploy -c staging.yml emres-server`

#### (OPTIONAL) Make emres-server service update order `start-first`
`docker service update --update-order 'start-first' emres-server_emres-server`

#### [FIRST BUILD] Seed admin and Infrastructure organization
`docker container exec -it [emres-server name] sh -c "bundle exec rails db:seed"`

## Update emres-server
#### Re-build the `emres-server` image
`docker build -t emres-server --rm .`

## Debugging
Make sure `emres-server` and `postgres` image is up and running.

To see the logs for `emres-server`
`docker container logs [emres-server name]`
