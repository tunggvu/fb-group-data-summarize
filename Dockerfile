FROM ruby:2.5-alpine
MAINTAINER Nam Chu "chu.hoang.nam@framgia.com"

# Setup arguments
ARG SECRET_KEY_BASE

# Minimal requirements to run a Rails app
RUN apk add --no-cache --update build-base tzdata postgresql-dev

ENV APP_PATH /emres-server

# Different layer for gems installation
WORKDIR $APP_PATH
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH
RUN bundle install --with production --without development test \
    --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` \
    --retry 3

ENV LANG='en_US.UTF-8'
ENV RACK_ENV='production'
ENV RAILS_ENV='production'
ENV RAILS_LOG_TO_STDOUT='enabled'
ENV RAILS_SERVE_STATIC_FILES='enabled'

ENV SECRET_KEY_BASE=$SECRET_KEY_BASE

# Copy the application into the container
COPY . $APP_PATH
COPY config/database.yml.docker /emres-server/config/database.yml

EXPOSE 3000