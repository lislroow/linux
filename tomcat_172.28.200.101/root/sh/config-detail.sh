#!/bin/bash

INSTANCE_BASE='/engn/servers'
LIST=($(cat <<- EOF

smpl
smpl_2

EOF
))

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
  for item in ${LIST[*]}; do
    configXml=${INSTANCE_BASE}/${item}/conf/server.xml
    if [[ ! -r ${configXml} ]]; then
      continue
    fi
    
    cnt=$(xmllint ${configXml} --xpath 'count(Server/GlobalNamingResources/Resource[@name!="UserDatabase"])')
    printf " # ${configXml}"
    printf $'\n'
    for (( idx=1; idx <= $cnt; idx++ )); do
      name=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@name)' )
      url=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@url)' )
      factory=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@factory)' )
      maxTotal=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@maxTotal)' )
      maxIdle=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@maxIdle)' )
      initialSize=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@initialSize)' )
      maxWait=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@maxWait)' )
      validationQuery=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@validationQuery)' )
      testOnBorrow=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@testOnBorrow)' )
      testOnConnect=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@testOnConnect)' )
      testWhileIdle=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@testWhileIdle)' )
      logAbandoned=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@logAbandoned)' )
      logValidationErrors=$( xmllint ${configXml} --xpath 'string(Server/GlobalNamingResources/Resource[@name!="UserDatabase"]['${idx}']/@logValidationErrors)' )
      
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
