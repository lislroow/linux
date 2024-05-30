#!/bin/bash
BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

JAVA_OPTS="-Dspring.config.additional-location=${BASE_DIR}/application.yml"
JAVA_OPTS="${JAVA_OPTS} --add-opens java.rmi/javax.rmi.ssl=ALL-UNNAMED"
nohup java ${JAVA_OPTS} -jar kafka-ui-api-v0.7.2.jar > ${BASE_DIR}/kafka-ui.out 2>&1 &

tail -f ${BASE_DIR}/kafka-ui.out

