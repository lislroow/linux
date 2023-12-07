#!/bin/bash

if [ -z $1 ]; then
  echo "Usage: ${0##*/} 'change-hostname'"
  exit -1
fi

hostnamectl set-hostname $1

