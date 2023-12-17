#!/bin/bash

INSTANCE_HOME=/engn/servers

printf "\e[0;32m[tomcat] basic \e[0m"
printf $'\n'
{
  LIST=($(ls ${INSTANCE_HOME}/*/conf/server.xml))
  printf "%10s %5s %5s %15s %5s %15s %5s %34s" \
         "inst" "shut" "http" \
         "cIp" "cPort" \
         "mIp" "mPort" "mId"
  printf $'\n'
  echo -e ''$_{1..102}'\b-'
  for item in ${LIST[*]}; do
    instanceId=$(echo ${item} | sed -n 's|'${INSTANCE_HOME}'/\(.*\)/conf/server.xml|\1|p')
    shutdownPort=$(xmllint ${item} --xpath 'string(/Server/@port)')
    httpPort=$(xmllint ${item} --xpath 'string(//Connector/@port)')
    clusterListenIp=$(xmllint ${item} --xpath 'string(Server/Service/Engine/Cluster/Channel/Receiver/@address)')
    clusterListenPort=$(xmllint ${item} --xpath 'string(Server/Service/Engine/Cluster/Channel/Receiver/@port)')
    clusterMemberHost=$(xmllint ${item} --xpath 'string(Server/Service/Engine/Cluster/Channel/Interceptor/Member/@host)')
    clusterMemberPort=$(xmllint ${item} --xpath 'string(Server/Service/Engine/Cluster/Channel/Interceptor/Member/@port)')
    clusterMemberId=$(xmllint ${item} --xpath 'string(Server/Service/Engine/Cluster/Channel/Interceptor/Member/@uniqueId)')
    
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
  LIST=($(ls ${INSTANCE_HOME}/*/conf/server.xml))
  printf "%10s %15s %12s %s" \
         "inst" "jndi" "username" "url"
  printf $'\n'
  echo -e ''$_{1..102}'\b-'
  for item in ${LIST[*]}; do
    cnt=$(xmllint ${item} --xpath 'count(Server/GlobalNamingResources/Resource[@name!="UserDatabase"])')
    instanceId=$(echo ${item} | sed -n 's|'${INSTANCE_HOME}'/\(.*\)/conf/server.xml|\1|p')
    for (( idx=1; idx <= $cnt; idx++ )); do
      jndi=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@name)' )
      username=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@username)' )
      url=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@url)' )
      
      printf "%10s %15s %12s %s" \
        ${instanceId} ${jndi} ${username} ${url}
      printf $'\n'
    done
  done
}
