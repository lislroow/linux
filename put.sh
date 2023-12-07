#!/bin/bash

tar cfz - tomcat_172.28.200.101/root | ssh root@172.28.200.101 'tar xfz - --strip-components=2 -C /root'
ssh root@172.28.200.101 'chown -R root:root /root'
ssh root@172.28.200.101 'chmod u+x /root/sh/*.sh'
