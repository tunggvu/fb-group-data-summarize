![CircleCI](https://circleci.com/gh/framgia/emres-server/tree/master.svg?style=svg&circle-token=cebf88f3f6124e9a2d0afa48690245c9de7b8499)

# README

Create Data:
* `rake db:seed_fu`

Create Data Without Send Email(recommended):
* `SEND_EMAIL=false rails db:seed_fu`
### Configure environments
The default environment file is `config/application.yml`.

There is an example file under the name `config/application.yml.sample`. In the
file, you will find necessary environment variables to configure the
application.

* SECRET_JWT PUBLIC_JWT you can generate base on RSA 2048
* Example http://csfieldguide.org.nz/en/interactives/rsa-key-generator/index.html
* Remember to replace NEW_LINE character by "\n" in application.yml

* SENDGRID_API_KEY: you can generate API key by create account in sendgrid: https://signup.sendgrid.com/,
  after that generate API key in https://app.sendgrid.com/settings/api_keys
## Documentation
* Read more at `public/docs`
* Accept from local server `localhost:3000/docs`
## Build Docker Image

#### Create data folder for postgres
`mkdir -p /data/emres-server/`

#### Create `application.yml.staging`
`cp config/application.yml.sample config/application.yml.staging`

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

## Build production server
#### Create `application.yml.production`
`cp config/application.yml.sample config/application.yml.production`\

#### Build production image
`docker build -t emres-server-production -f Dockerfile_production .`

#### Initialize database
`docker-compose run --rm server-3 bundle exec rake db:create`

`docker-compose run --rm server-3 bundle exec rake db:migrate`

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
