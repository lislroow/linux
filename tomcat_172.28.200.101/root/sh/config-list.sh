#!/bin/bash

INSTANCE_BASE='/engn/servers'
LIST=($(ls /engn/servers))
#LIST=($(cat <<- EOF
#
#smpl
#smpl_2
#
#EOF
#))

printf "\e[0;32m[tomcat] basic \e[0m"
printf $'\n'
{
  printf "%10s %5s %5s %15s %5s %15s %5s %34s" \
         "inst" "shut" "http" \
         "cIp" "cPort" \
         "mIp" "mPort" "mId"
  printf $'\n'
  echo -e ''$_{1..102}'\b-'
  for item in ${LIST[*]}; do
    configXml=${INSTANCE_BASE}/${item}/conf/server.xml
    if [[ ! -r ${configXml} ]]; then
      continue
    fi
    
    instanceId=$(echo ${configXml} | sed -n 's|'${INSTANCE_BASE}'/\(.*\)/conf/server.xml|\1|p')
    shutdownPort=$(xmllint ${configXml} --xpath 'string(/Server/@port)')
    httpPort=$(xmllint ${configXml} --xpath 'string(//Connector/@port)')
    clusterListenIp=$(xmllint ${configXml} --xpath 'string(Server/Service/Engine/Cluster/Channel/Receiver/@address)')
    clusterListenPort=$(xmllint ${configXml} --xpath 'string(Server/Service/Engine/Cluster/Channel/Receiver/@port)')
    clusterMemberHost=$(xmllint ${configXml} --xpath 'string(Server/Service/Engine/Cluster/Channel/Interceptor/Member/@host)')
    clusterMemberPort=$(xmllint ${configXml} --xpath 'string(Server/Service/Engine/Cluster/Channel/Interceptor/Member/@port)')
    clusterMemberId=$(xmllint ${configXml} --xpath 'string(Server/Service/Engine/Cluster/Channel/Interceptor/Member/@uniqueId)')
    
    printf "%10s %5s %5s %15s %5s %15s %5s %34s" \
      ${instanceId} ${shutdownPort} ${httpPort} \
      ${clusterListenIp} ${clusterListenPort} \
      ${clusterMemberHost} ${clusterMemberPort} ${clusterMemberId}
    printf $'\n'
  done
}

printf $'\n'
printf "\e[0;32m[tomcat] jndi \e[0m"
printf $'\n'
{
  printf "%10s %15s %12s %s" \
         "inst" "jndi" "username" "url"
  printf $'\n'
  echo -e ''$_{1..102}'\b-'
  for item in ${LIST[*]}; do
    configXml=${INSTANCE_BASE}/${item}/conf/server.xml
    if [[ ! -r ${configXml} ]]; then
      continue
    fi
    
    cnt=$(xmllint ${configXml} --xpath 'count(Server/GlobalNamingResources/Resource[@name!="UserDatabase"])')
    instanceId=$(echo ${configXml} | sed -n 's|'${INSTANCE_BASE}'/\(.*\)/conf/server.xml|\1|p')
    for (( idx=1; idx <= $cnt; idx++ )); do
      jndi=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@name)' )
      username=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@username)' )
      url=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@url)' )
      
      printf "%10s %15s %12s %s" \
        ${instanceId} ${jndi} ${username} ${url}
      printf $'\n'
    done
  done
}
