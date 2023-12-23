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

function build {
  HUGO_OPTS=""
  HUGO_OPTS="${HUGO_OPTS} --cleanDestinationDir"
  
  HUGO_CMD="${HUGO} ${HUGO_OPTS}"
  echo -e "\e[0;32m${HUGO_CMD}\e[0m"
  eval ${HUGO_CMD}
}

case $1 in
  server)
    server;
    ;;
  build)
    build;
    ;;
  *)
    server;
    ;;
esac
