#!/bin/bash

if [ ! -e tomcat_172.28.200.101 ]; then
  mkdir tomcat_172.28.200.101
fi

ssh root@172.28.200.101 'sh /root/sh/host-backup.sh'
ssh root@172.28.200.101 'tar cfz - /root/backup-tomcat_172.28.200.101.tar 2> /dev/null' \
  | tar xvfz - --strip-components=1 -C tomcat_172.28.200.101 2>&1 > /dev/null
ssh root@172.28.200.101 'rm -rf /root/backup-*.tar'
tar xf tomcat_172.28.200.101/backup-tomcat_172.28.200.101.tar -C tomcat_172.28.200.101 2>&1 > /dev/null
rm -rf tomcat_172.28.200.101/backup-tomcat_172.28.200.101.tar

