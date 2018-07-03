![CircleCI](https://circleci.com/gh/framgia/emres-server/tree/master.svg?style=svg&circle-token=cebf88f3f6124e9a2d0afa48690245c9de7b8499)

# README

Create Data:
* rake db:seed_fu

## Build Docker Image

#### Create data folder for postgres
`mkdir -p /data/emres-server/`

#### Set SECRET_KEY_BASE
`rails secret | docker secret create rails_secret -`

#### Build the latest version
`docker build -t emres-server --rm .`

#### Deploy emres-server with postgres
`docker stack deploy -c docker-compose.yml emres-server`

#### (OPTIONAL) Make emres-server service update order `start-first`
`docker service update --update-order 'start-first' emres-server_emres-server`

#### Update the emres-server to the latest version
`docker service update --image emres-server emres-server_emres-server`
