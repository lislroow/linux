#!/usr/bin/env bash

nohup /c/develop/tools/java/corretto-1.8.0_382/bin/java -Xmx1024m -classpath ./scouter-server-boot.jar scouter.boot.Boot ./lib > nohup.out &
sleep 1
tail -100 nohup.out

