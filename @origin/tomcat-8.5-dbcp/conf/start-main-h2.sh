#!/bin/bash

BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

export JAVA_HOME='/c/develop/tools/java/corretto-1.8.0_382'
export MAVEN_HOME='/c/develop/tools/maven'
export PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH"

if [ -z $(which java 2> /dev/null) ]; then
  echo "java not found"
  exit 1
fi
if [ -z $(which mvn 2> /dev/null) ]; then
  echo "maven not found"
  exit 1
fi

H2_JAR='h2-2.2.224.jar'
if [ ! -e $H2_JAR ]; then
  mvn dependency:copy -Dartifact=com.h2database:h2:2.2.224:jar -DoutputDirectory=.
fi

java -jar h2-2.2.224.jar \
  -tcp -tcpAllowOthers -tcpPort 9092 \
  -web -webPort 9093 \
  -baseDir ~/

