#!/bin/bash

export KAFKA_HOME='/opt/kafka-3.7'
export PATH="$KAFKA_HOME/bin:$PATH"
export JAVA_HOME='/opt/corretto-17'
export PATH="$JAVA_HOME/bin:$PATH"

nohup $KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > $KAFKA_HOME/zookeeper.out 2>&1 &
tail -f $KAFKA_HOME/zookeeper.out

