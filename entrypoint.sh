#!/usr/bin/env bash

if [ ! -f /root/.syscoin/syscoin.conf ]; then
  cp /syscoin/syscoin.conf /root/.syscoin/syscoin.conf
  sed -i "s/CHANGEME/$RANDOM/g" /root/.syscoin/syscoin.conf
fi

if [[ "" == "$@" ]]; then
  exec "syscoind"
else
  exec "$@"
fi
