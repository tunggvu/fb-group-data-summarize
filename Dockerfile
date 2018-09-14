FROM ruby:2.5
MAINTAINER Nam Chu "chu.hoang.nam@framgia.com"

# Minimal requirements to run a Rails app
RUN apt-get update; \
    apt-get upgrade -y; \
    apt-get install -y build-essential libpq-dev libyaml-dev libssl-dev \
      libreadline-dev

ENV APP_PATH /emres-server

# Different layer for gems installation
WORKDIR $APP_PATH
ADD Gemfile $APP_PATH
ADD Gemfile.lock $APP_PATH
RUN bundle install --with production --without development test \
    --jobs `expr $(cat /proc/cpuinfo | grep -c "cpu cores") - 1` \
    --retry 3
RUN ln -fs /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime; \
    dpkg-reconfigure -f noninteractive tzdata;

ENV LANG='en_US.UTF-8'
ENV RAILS_LOG_TO_STDOUT='enabled'
ENV RAILS_SERVE_STATIC_FILES='enabled'

# Copy the application into the container
COPY . $APP_PATH
COPY config/database.yml.docker $APP_PATH/config/database.yml
COPY config/application.yml.staging $APP_PATH/config/application.yml

EXPOSE 3000
