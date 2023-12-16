#!/bin/bash

LIST=($(cat <<- EOF

172.28.200.101:tomcat

EOF
))


read -r rows <<< ${LIST[*]}
idx=0
for item in ${LIST[*]}; do
  ((idx++))
  if [[ "${item}" == "#"* ]]; then
    printf "\e[0;31m ## ${idx}) ${item} (SKIP) \e[0m%s" $'\n'
    continue
  fi
  
  ip=${item%:*}
  hostnm=${item##*:}
  
  gzFile="backup-${hostnm}.tar.gz"
  outDir="${hostnm}_${ip}"
  printf "\e[0;31m ## ${idx}) ${ip} ${hostnm} \e[0m%s" $'\n'
  
  if [ ! -e ${outDir} ]; then
    mkdir ${outDir}
  fi
  
  ssh root@${ip} "sh /root/sh/host-backup.sh"
  
  printf " transering ... "
  ssh root@${ip} "tar cfz - /root/${gzFile} 2> /dev/null" \
    | tar xvfz - --strip-components=1 -C ${outDir} 2>&1 > /dev/null
  printf "done%s" $'\n'
  
  if [ ${gzFile} != "" ]; then
    printf " deleting remote ${gzFile} ... "
    ssh root@${ip} "rm -rf /root/${gzFile}"
    printf "done%s" $'\n'
  fi
  
  printf " extracting ${gzFile} to ./${outDir}/ ... "
  tar xfz ${outDir}/${gzFile} -C ./${outDir}/ 2>&1 > /dev/null
  printf "done%s" $'\n'
  
  if [ -e ${outDir}/${gzFile} ]; then
    printf " deleting local ${gzFile} ... "
    rm -rf ${outDir}/${gzFile}
    printf "done%s" $'\n'
  fi
done

