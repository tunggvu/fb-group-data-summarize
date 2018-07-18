#!/bin/sh
service cron start
bundle exec whenever --update-crontab --set environment='staging'
bundle exec rake project_feature:update_message_review
