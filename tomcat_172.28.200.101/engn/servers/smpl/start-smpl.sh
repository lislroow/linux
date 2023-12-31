#!/bin/bash

BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

INSTANCE_ID="smpl"
EXEC_USER="root"
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.392.b08-4.el8_8.x86_64
CATALINA_HOME=/engn/tomcat/tomcat-8.5.96
LOG_BASE="/logs/${INSTANCE_ID}"

PATH=$JAVA_HOME/bin:$PATH

if [ ! -e $LOG_BASE ]; then
  mkdir -p $LOG_BASE
fi

CATALINA_BASE=$BASE_DIR
CATALINA_TMPDIR=$CATALINA_HOME/temp
CATALINA_OUT="${LOG_BASE}/${INSTANCE_ID}-tomcat_console.log"

echo "tomcat starting"

if [ `whoami` != "${EXEC_USER}" ]; then
  echo "please execute \"${EXEC_USER}\""
  exit 1
fi

pid=$( ps -ef | grep "instance.id=${INSTANCE_ID} " | grep -v grep | awk '{print $2}' )
if [ ! -z "$pid" ]; then
  echo "tomcat already running. please check pid \"${pid}\""
  exit 1
fi

SCOUTER_AGENT_DIR=/engn/scouter/agent.java
JAVA_OPTS="-server"
JAVA_OPTS="${JAVA_OPTS} -Xms512m -Xmx512m"
JAVA_OPTS="${JAVA_OPTS} -verbose:gc"
JAVA_OPTS="${JAVA_OPTS} -Xloggc:${LOG_BASE}/gc/`date +%Y%m%d_%H%M%S`-gc.log"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCDetails"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCDateStamps"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintHeapAtGC"
JAVA_OPTS="${JAVA_OPTS} -XX:+UseGCLogFileRotation"
JAVA_OPTS="${JAVA_OPTS} -XX:+ExitOnOutOfMemoryError"
JAVA_OPTS="${JAVA_OPTS} -XX:+HeapDumpOnOutOfMemoryError"
JAVA_OPTS="${JAVA_OPTS} -XX:HeapDumpPath=${LOG_BASE}/dump_${INSTANCE_ID}_`date+%Y%m%d_%H%M%S`.hprof"
JAVA_OPTS="${JAVA_OPTS} -XX:+DisableExplicitGC"
JAVA_OPTS="${JAVA_OPTS} -Dinstance.id=${INSTANCE_ID}"
JAVA_OPTS="${JAVA_OPTS} -Dlog.base=${LOG_BASE}"
JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=utf-8"
JAVA_OPTS="${JAVA_OPTS} -Djava.library.path=${BASE_DIR}/lib"
JAVA_OPTS="${JAVA_OPTS} -Doracle.jdbc.autoCommitSpecCompliant=false"
JAVA_OPTS="${JAVA_OPTS} -javaagent:${SCOUTER_AGENT_DIR}/scouter.agent.jar"
JAVA_OPTS="${JAVA_OPTS} -Dscuter.config=${SCOUTER_AGENT_DIR}/conf/scouter.conf"
JAVA_OPTS="${JAVA_OPTS} -Dobj_name=${INSTANCE_ID}_1"
JAVA_OPTS="${JAVA_OPTS} -Djava.net.preferIPv4Stack=true"

source ${CATALINA_HOME}/bin/catalina.sh start "$@"
