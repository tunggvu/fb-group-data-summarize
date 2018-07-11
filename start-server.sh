#!/bin/sh

bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails server -p 3000 -b "0.0.0.0"
bundle exec whenever --update-crontab
