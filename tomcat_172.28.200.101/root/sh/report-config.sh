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
  for item in ${LIST[*]}; do
    cnt=$(xmllint ${item} --xpath 'count(Server/GlobalNamingResources/Resource[@name!="UserDatabase"])')
    
    printf " # ${item}"
    printf $'\n'
    for (( idx=1; idx <= $cnt; idx++ )); do
      name=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@name)' )
      url=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@url)' )
      factory=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@factory)' )
      maxTotal=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@maxTotal)' )
      maxIdle=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@maxIdle)' )
      initialSize=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@initialSize)' )
      maxWait=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@maxWait)' )
      validationQuery=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@validationQuery)' )
      testOnBorrow=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@testOnBorrow)' )
      testOnConnect=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@testOnConnect)' )
      testWhileIdle=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@testWhileIdle)' )
      logAbandoned=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@logAbandoned)' )
      logValidationErrors=$( xmllint ${item} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@logValidationErrors)' )
      
      cat << EOF
   attr-name           | attr-value
   -------------------------------------------------------------------------------
   name                | ${name}
   url                 | ${url}
   factory             | ${factory}
   maxTotal            | ${maxIdle}
   initialSize         | ${maxWait}
   validationQuery     | ${validationQuery}
   testOnBorrow        | ${testOnBorrow}
   testOnConnect       | ${testOnConnect}
   testWhileIdle       | ${testWhileIdle}
   logAbandoned        | ${logAbandoned}
   logValidationErrors | ${logValidationErrors}
EOF
    printf $'\n'
    done
  done
}
