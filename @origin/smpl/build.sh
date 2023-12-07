#!/bin/bash

BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

JAVA_HOME=/c/develop/tools/java/corretto-1.8.0_382
#JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.392.b08-4.el8_8.x86_64
PATH=$JAVA_HOME/bin:$PATH
MAVEN_HOME=/c/develop/tools/maven
PATH=$MAVEN_HOME/bin:$PATH

mvn -f $BASE_DIR/pom.xml clean package
