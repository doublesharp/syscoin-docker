#!/usr/bin/env bash

set -e

if [ ! -f /home/syscoin/.syscoin/syscoin.conf ]; then
  cp /syscoin/syscoin.conf /home/syscoin/.syscoin/syscoin.conf
  sed -i "s/CHANGEME/$RANDOM/g" /home/syscoin/.syscoin/syscoin.conf
fi

if [[ "" == "$@" ]]; then
  exec "syscoind"
else
  exec "$@"
fi
