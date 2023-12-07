#!/bin/bash

BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

nohup java -classpath $BASE_DIR/scouter.host.jar scouter.boot.Boot $BASE_DIR/lib > nohup.out &

