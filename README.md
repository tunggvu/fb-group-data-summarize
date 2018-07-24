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

#### Build `haproxy-socat` image
To build `haproxy-socat`, run `docker build -t haproxy-socat -f haproxy/haproxy_Dockerfile .`

#### Build the latest version
`docker build -t emres-server --rm .`

To build the latest version for `emres-front`, change directory to `emres-front`
directory and run command `docker build -t emres-front --rm .`

### Initialize database and seed data
`docker-compose run --rm server-1 bundle exec rake db:create`

`docker-compose run --rm server-1 bundle exec rake db:migrate`

`docker-compose run --rm server-1 bundle exec rake db:seed_fu`

### Start EMRES
To start `emres-server` and `emres-front`, run command `docker-compose up -d`

Docker will start 4 instances of `emres-server`, 4 instances of `emres-front` 
and an instance of `haproxy` to proxy those 8 instances. And the `haproxy`
monitoring service is run on `.:8870`

`emres-front` will run on `.:8880`

`emres-server` will run on `.:8890`

## Upgrade server
To upgrade `emres-server` to the latest version, please checkout to the latest
version on git, re-build `emres-server` image and run `./upgrade-server.sh`

The script will take care of rolling out the latest version to `emres-server`
containers.

## Shutdown and Wipe Data
To shutdown `emres-server` and `emres-front`, run `docker-compose down`

All containers for EMRES will be shutdown and delete. This action is
irreversible. **BUT** the data for database will remain untouched.

The database's data and configuration files are stored at `/data/emres-server/`,
delete that directory will cause data loss for the database
