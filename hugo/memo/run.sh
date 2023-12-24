#!/bin/bash

BASE_DIR=$( cd $( dirname $0 ) && pwd -P )
HUGO=${BASE_DIR%/*}/bin/hugo

HUGO_VERSION=$( $HUGO version )
echo -e "\e[0;32m${HUGO_VERSION}\e[0m"

function server {
  HUGO_OPTS=""
  HUGO_OPTS="${HUGO_OPTS} --bind=0.0.0.0"
  HUGO_OPTS="${HUGO_OPTS} --port=80"
  HUGO_OPTS="${HUGO_OPTS} --buildDrafts"
  
  HUGO_CMD="${HUGO} server ${HUGO_OPTS}"
  echo -e "\e[0;32m${HUGO_CMD}\e[0m"
  eval ${HUGO_CMD}
}

function deploy {
  HUGO_OPTS=""
  HUGO_OPTS="${HUGO_OPTS} --cleanDestinationDir"
  
  HUGO_CMD="${HUGO} ${HUGO_OPTS}"
  echo -e "\e[0;32m${HUGO_CMD}\e[0m"
  eval ${HUGO_CMD}
  
  CMD="rm -rf lislroow.github.io/*"
  echo -e "\e[0;32m${CMD}\e[0m"
  eval ${CMD}
  
  CMD="cp -R public/* lislroow.github.io/"
  echo -e "\e[0;32m${CMD}\e[0m"
  eval ${CMD}
  
  CMD="cd lislroow.github.io/ && git add . && git commit -m 'update' && git push origin master"
  echo -e "\e[0;32m${CMD}\e[0m"
  eval ${CMD}
}

function staging {
  HUGO_OPTS=""
  HUGO_OPTS="${HUGO_OPTS} --cleanDestinationDir"
  
  HUGO_CMD="${HUGO} ${HUGO_OPTS}"
  echo -e "\e[0;32m${HUGO_CMD}\e[0m"
  eval ${HUGO_CMD}
  
  CMD="tar cfz - public/* | ssh root@172.28.200.101 'tar xfz - --strip-components=1 -C /sorc/memo'"
  echo -e "\e[0;32m${CMD}\e[0m"
  eval ${CMD}
}

case $1 in
  server)
    server;
    ;;
  deploy)
    deploy;
    ;;
  staging)
    staging;
    ;;
  *)
    server;
    ;;
esac
