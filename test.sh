#!/bin/bash

while true
do
  echo -n `date +"[%m-%d-%y %H:%M:%S]"`
  curl localhost:8001/api/v1/
  echo
  sleep 1
done
