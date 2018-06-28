![CircleCI](https://circleci.com/gh/framgia/emres-server/tree/master.svg?style=svg&circle-token=cebf88f3f6124e9a2d0afa48690245c9de7b8499)

# README

Create Data:
* rake db:seed_fu

## Build Docker Image

`docker-compose build emres-server` will create emresserver_emres-server and
emresserver_postgres images.

Run `docker-compose run -e SECRET_KEY_BASE="[rails secret key]" --service-ports
emres-server`
