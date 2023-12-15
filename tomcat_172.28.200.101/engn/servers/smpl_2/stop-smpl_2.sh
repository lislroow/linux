#!/bin/bash

BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

INSTANCE_ID="smpl_2"
EXEC_USER="tomcat"
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.392.b08-4.el8_8.x86_64
CATALINA_HOME=/engn/tomcat/tomcat-8.5.96

PATH=$JAVA_HOME/bin:$PATH

CATALINA_BASE=$BASE_DIR

echo "tomcat stopping"

pid=$( ps -ef | grep "instance.id=${INSTANCE_ID} " | grep -v grep | awk '{print $2}' )
if [ -z "$pid" ]; then
  echo "tomcat is not running."
  exit 1
fi

source ${CATALINA_HOME}/bin/catalina.sh stop "$@"

for i in {1..1}; do
  printf "."
  pid=$( ps -ef | grep "instance.id=${INSTANCE_ID} " | grep -v grep | awk '{print $2}' )
  if [ "${pid}" != "" ]; then
    sleep 1
  else
    break
  fi
done
printf $'\n'

if [ "${pid}" != "" ]; then
  kill -15 "${pid}"
fi

echo "tomcat stopped"

