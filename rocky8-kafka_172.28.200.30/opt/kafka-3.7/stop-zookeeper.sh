#!/bin/bash

export KAFKA_HOME='/opt/kafka-3.7'
export PATH="$KAFKA_HOME/bin:$PATH"
export JAVA_HOME='/opt/corretto-17'
export PATH="$JAVA_HOME/bin:$PATH"

$KAFKA_HOME/bin/zookeeper-server-stop.sh

