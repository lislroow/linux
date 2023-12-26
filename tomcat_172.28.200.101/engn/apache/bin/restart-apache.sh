#!/bin/bash

BASE_DIR=$( cd $(dirname $0) && pwd -P)

$BASE_DIR/apachectl graceful-stop
$BASE_DIR/apachectl start
