![CircleCI](https://circleci.com/gh/framgia/emres-server/tree/master.svg?style=svg&circle-token=cebf88f3f6124e9a2d0afa48690245c9de7b8499)

# README

Create Data:
* `rake db:seed_fu`

## Build Docker Image

#### Create data folder for postgres
`mkdir -p /data/emres-server/`

#### Create `application.yml`
`cp config/application.yml.sample config/application.yml`

**You should update the environment variable inside this file to make the
application run correctly**

#### Build the latest version
`docker build -t emres-server --rm .`

### Initialize database and seed data
`docker-compose run --rm server-1 bundle exec rake db:create`
`docker-compose run --rm server-1 bundle exec rake db:migrate`
`docker-compose run --rm server-1 bundle exec rake db:seed_fu`

### Start EMRES
To start `emres-server`, run command `docker-compose up -d`

Docker will start 3 instances of `emres-server` and an instance of `haproxy` to
proxy those 3 instances. And the `haproxy` monitoring service is run on `.:8010`

## Upgrade server
To upgrade `emres-server` to the latest version, please checkout to the latest
version on git and run `./upgrade.sh`. 

## Shutdown and Wipe Data
To shutdown `emres-server`, run `docker-compose down`

All containers for `emres-server` will be shutdown and delete. This action is
irreversible. **BUT** the data for database will remain untouched.

The database's data and configuration files are stored at `/data/emres-server/`,
delete that directory will cause data loss for the database
