#!/bin/bash

#[ref]
# printf "\e[0;32m text \e[0m"


odir=$HOME
host=`hostname`
ipaddr=`ifconfig ens32 | sed -n 's|.*inet \([^ ]*\)  netmask.*|\1|p'`
ofile=${odir}/backup-${host}_${ipaddr}.tar
ouser=root

USER_LIST=($(cat <<- EOF
EOF
))

printf "\e[0;32m [backup] tar cf ${ofile} /engn \e[0m"
tar cf ${ofile} /engn 2> /dev/null
if [ $? -eq 0 ]; then
  printf "... OK %s" $'\n'
else
  printf "... \e[0;32mError\e[0m %s" $'\n'
fi
chown ${ouser}:${ouser} ${ofile}

if [ -e /data ]; then
  printf "\e[0;32m [backup] tar rf ${ofile} /data \e[0m"
  tar rf ${ofile} /data 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... OK %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
fi

if [ -e /sorc ]; then
  printf "\e[0;32m [backup] tar rf ${ofile} /sorc \e[0m"
  tar rf ${ofile} /sorc 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... OK %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
fi

if [ -e /etc/logrotate.d ]; then
  tar rf ${ofile} /etc/logrotate.d/apache 2> /dev/null
  tar rf ${ofile} /etc/logrotate.d/smpl 2> /dev/null
fi

if [ -e /etc/systemd/system ]; then
  tar rf ${ofile} /etc/systemd/system/scouter-server.service 2> /dev/null
  tar rf ${ofile} /etc/systemd/system/scouter-agent.host.service 2> /dev/null
fi

if [ -e /root/sh ]; then
  printf "\e[0;32m [backup] tar rf ${ofile} /root/sh \e[0m"
  tar rf ${ofile} /root/sh 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... OK %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
fi

read -r userList <<< ${USER_LIST[*]}
idx=1
for userId in ${userList[*]}; do
  if [ ! -e "/home/${userId}" ]; then
    continue
  fi
  
  printf "\e[0;32m [backup] tar rf ${ofile} /home/${userId}/sh \e[0m"
  tar rf ${ofile} /home/${userId}/sh 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... OK %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
  
  printf "\e[0;32m [backup] tar rf ${ofile} /home/${userId}/.bash_profile \e[0m"
  tar rf ${ofile} /home/${userId}/.bash_profile 2> /dev/null
  if [ $? -eq 0 ]; then
    printf "... OK %s" $'\n'
  else
    printf "... \e[0;32mError\e[0m %s" $'\n'
  fi
done

echo "output file: ${ofile}"


