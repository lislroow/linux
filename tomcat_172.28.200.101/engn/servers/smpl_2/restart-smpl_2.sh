#!/bin/bash

BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

INSTANCE_ID="smpl_2"

source $BASE_DIR/stop-${INSTANCE_ID}.sh
sleep 1
source $BASE_DIR/start-${INSTANCE_ID}.sh

