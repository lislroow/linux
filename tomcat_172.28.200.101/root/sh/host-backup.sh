#!/bin/bash

#[ref]
# printf "\e[0;32m text \e[0m"


odir=$HOME
host=`hostname`
ipaddr=`ifconfig ens32 | sed -n 's|.*inet \([^ ]*\)  netmask.*|\1|p'`
tarFile=${odir}/backup-${host}.tar
gzFile=${tarFile}.gz
ouser=root

USER_LIST=($(cat <<- EOF
EOF
))

printf "\e[0;32m [backup] tar cf ${tarFile} --exclude 'tomcat' --exclude 'work' --exclude 'logs' /engn \e[0m"
tar cf ${tarFile} --exclude 'tomcat' --exclude 'work' --exclude 'logs' /engn 2> /dev/null
if [ $? -eq 0 ]; then
  printf "... done %s" $'\n'
else
  printf "... \e[0;32mError\e[0m %s" $'\n'
fi

if [ -e /data ]; then
  printf "\e[0;32m [backup] tar rf ${tarFile} /data \e[0m"
  tar rf ${tarFile} /data 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... done %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
fi

if [ -e /sorc ]; then
  printf "\e[0;32m [backup] tar rf ${tarFile} /sorc \e[0m"
  tar rf ${tarFile} /sorc 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... done %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
fi

if [ -e /etc/logrotate.d ]; then
  tar rf ${tarFile} /etc/logrotate.d/apache 2> /dev/null
  tar rf ${tarFile} /etc/logrotate.d/smpl 2> /dev/null
fi

if [ -e /etc/systemd/system ]; then
  tar rf ${tarFile} /etc/systemd/system/scouter-server.service 2> /dev/null
  tar rf ${tarFile} /etc/systemd/system/scouter-agent.host.service 2> /dev/null
fi

if [ -e /root/sh ]; then
  printf "\e[0;32m [backup] tar rf ${tarFile} /root/.bash_profile /root/sh \e[0m"
  tar rf ${tarFile} /root/.bash_profile /root/sh 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... done %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
fi

read -r userList <<< ${USER_LIST[*]}
idx=0
for userId in ${userList[*]}; do
  ((idx++))
  if [ ! -e "/home/${userId}" ]; then
    continue
  fi
  
  printf "\e[0;32m [backup] tar rf ${tarFile} /home/${userId}/sh \e[0m"
  tar rf ${tarFile} /home/${userId}/sh 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... done %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
  
  printf "\e[0;32m [backup] tar rf ${tarFile} /home/${userId}/.bash_prtarFile \e[0m"
  tar rf ${tarFile} /home/${userId}/.bash_prtarFile 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... done %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
done

printf " compress ... "
gzip ${tarFile}
printf "done%s" $'\n'
chown ${ouser}:${ouser} ${gzFile}

printf "\e[0;32m [output] ${gzFile} \e[0m %s" $'\n'



