#!/bin/bash

while true
do
  echo -n `date +"[%m-%d-%y %H:%M:%S]"`
  curl localhost:8890/api/v1/
  echo
  sleep 0.2
done
