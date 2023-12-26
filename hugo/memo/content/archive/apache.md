## `Ⅰ. apache`

- 버전: apache 2.4.x

### 1. 다운로드

다운로드 후 tar zxvf *.tar.gz 로 압축 해제 합니다.

```shell
$ wget https://dlcdn.apache.org/httpd/httpd-2.4.58.tar.gz
$ wget https://dlcdn.apache.org/apr/apr-1.7.4.tar.gz
$ wget https://dlcdn.apache.org/apr/apr-util-1.6.3.tar.gz
$ wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz
```

### 2. 설치

#### 1) 의존성 설치

```shell
$ yum install expat-devel
$ cd /opt/apache/apr-1.7.4 && \
  ./configure \
    --prefix=/usr/local/src/apr-1.7.4 && \
  make && \
  make install
$ cd /opt/apache/apr-util-1.6.3 && \
  ./configure \
    --prefix=/usr/local/src/apr-util-1.6.3 \
    --with-apr=/usr/local/src/apr-1.7.4 && \
  make && \
  make install
$ cd /opt/apache/pcre2-10.42 && \
  ./configure \
    --prefix=/usr/local/src/pcre2-10.42 \
    --with-apr=/usr/local/src/apr-1.7.4 && \
  make && \
  make install
```

#### 2) 설치

```shell
# no-ssl compile
$ cd /opt/apache/httpd-2.4.58 && \
  ./configure \
    --prefix=/engn/apache \
    --enable-modules=most \
    --enable-mods-shared=all \
    --enable-so \
    --with-mpm=prefork \
    --with-apr=/usr/local/src/apr-1.7.4 \
    --with-apr-util=/usr/local/src/apr-util-1.6.3 \
    --with-pcre=/usr/local/src/pcre2-10.42 && \
  make && \
  make install
# with-ssl compile
$ cd /opt/apache/httpd-2.4.58 && \
  ./configure \
    --prefix=/engn/apache \
    --enable-modules=most \
    --enable-mods-shared=all \
    --enable-ssl \
    --with-ssl=/usr/bin/openssl \
    --enable-so \
    --with-mpm=prefork \
    --with-apr=/usr/local/src/apr-1.7.4 \
    --with-apr-util=/usr/local/src/apr-util-1.6.3 \
    --with-pcre=/usr/local/src/pcre2-10.42
  make && \
  make install
```

### 3. 설정

#### 1) 기본 항목

- User, Group 설정: `User apache`, `Group apache`
- 디렉토리 설정: `DocumentRoot`, `<Directory>`, `<Location>`
  ```apacheconf
  DocumentRoot "/sorc/apache"
  <Directory />
    AllowOverride AuthConfig
    Require all denied
    <LimitExcept GET POST OPTIONS>
      Order allow,deny
      Allow from all
    </LimitExcept>
  </Directory>
  <Location "/">
    Require all granted
  </Location>
  ```
- 로그 설정: `LogFormat` 에 %{X-Forward-For}i  %I %O 추가
  ```apacheconf
  <IfModule log_config_module>
    LogFormat "%{X-Forward-For}i %h %l %u %t \"%r\" %>s %b \"%{Referer}i\"" combined
    LogFormat "%{X-Forward-For}i %h %l %u %t \"%r\" %>s %b" common
  
    <IfModule logio_module>
      LogFormat "%{X-Forward-For}i %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" %I %O" combinedio
    </IfModule>
  
    CustomLog "/logs/apache/access_log" combinedio
  </IfModule>
  ```
- 서버 정보 노출: `ServerTokens Prod`, `ServerSignature Off`

  (Prod: 웹서버의 이름만 표시, Full 은 전체 표시)
  ```apacheconf
  ServerTokens Prod
  ServerSignature Off
  ```

#### 2) 성능 및 옵션

- mpm 설정: `mpm_prefork_module`
  ```apacheconf
  <IfModule mpm_prefork_module>
    ServerLimit           1024
    StartServers             5
    MinSpareServers          5
    MaxSpareServers         10
    MaxRequestWorkers     1024
    MaxConnectionsPerChild   0
  </IfModule>
  ```
- request body 크기 제한 설정
  ```apacheconf
  LimitRequestBody 2147483647
  ```
- mod_status, mod_info 설정
  ```apacheconf
  <Location /server-info>
    SetHandler server-info
    Require all denied
    Require ip 172.28.200.1
  </Location>
  <Location /server-status>
    SetHandler server-status
    Require all denied
    Require ip 172.28.200.1
  </Location>
  ExtendedStatus On
  ```

#### 3) 가상호스트 및 proxy 설정

```apacheconf
<VirtualHost *:80>
  ServerName smpl.develop.net
  
  ErrorLog "/logs/smpl/smpl-apache_error.log"
  CustomLog "/logs/smpl/smpl-apache_access.log" combinedio
  
  DocumentRoot "/sorc/smpl/web"
  
  Header always edit Set-Cookie (.*) "$1; Secure; SameSite=None;"
  
  ProxyRequests Off
  ProxyPreserveHost On
  
  Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED
  
  <Proxy balancer://cluster>
    BalancerMember http://172.28.200.101:8010 route=cluster1 retry=1 acquire=3000 timeout=10000 Keepalive=On
    BalancerMember http://172.28.200.101:8011 route=cluster2 retry=1 acquire=3000 timeout=10000 Keepalive=On
    
    ProxySet stickysession=ROUTEID
    ProxySet lbmethod=byrequests
  </Proxy>
  
  ProxyPassMatch ^/$          balancer://cluster
  ProxyPassMatch /health      balancer://cluster
  ProxyPassMatch /api/(.*)    balancer://cluster
  ProxyPassMatch /(.*\.jsp.*) balancer://cluster
</VirtualHost>
```

#### 4) SSL 인증서 적용

```apacheconf
# conf/httpd.conf
LoadModule socache_shmcb_module modules/mod_socache_shmcb.so
LoadModule ssl_module modules/mod_ssl.so

Include conf/ssl.conf
Include conf/vhost-memo.conf
Include conf/vhost-smpl.conf


# conf/ssl.conf
Listen 443

SSLCipherSuite HIGH:MEDIUM:!MD5:!RC4:!3DES
SSLProxyCipherSuite HIGH:MEDIUM:!MD5:!RC4:!3DES

SSLHonorCipherOrder on 

SSLProtocol all -SSLv3
SSLProxyProtocol all -SSLv3

SSLPassPhraseDialog  builtin

SSLSessionCache        "shmcb:/engn/apache/logs/ssl_scache(512000)"
SSLSessionCacheTimeout  300


# conf/vhost-memo.conf
# memo.develop.net
<VirtualHost *:80>
  ServerName memo.develop.net
  
  DocumentRoot "/sorc/memo"
  
  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteRule /(.*) https://%{HTTP_HOST}/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName memo.develop.net

  DocumentRoot "/sorc/memo"

  ErrorLog "/logs/memo/error_log"
  TransferLog "/logs/memo/access_log"

  SSLEngine on

  SSLCertificateFile "/engn/apache/conf/star.develop.net.crt"
  SSLCertificateKeyFile "/engn/apache/conf/star.develop.net.key"
</VirtualHost>


# conf/vhost-smpl.conf
# smpl.develop.net
<VirtualHost *:80>
  ServerName smpl.develop.net

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteRule /(.*) https://%{HTTP_HOST}/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName smpl.develop.net
  
  ErrorLog "/logs/smpl/smpl-apache_error.log"
  CustomLog "/logs/smpl/smpl-apache_access.log" combinedio
  
  DocumentRoot "/sorc/smpl/web"
  
  Header always edit Set-Cookie (.*) "$1; Secure; SameSite=None;"
  
  ProxyRequests Off
  ProxyPreserveHost On
  
  Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED
  
  <Proxy balancer://cluster>
    BalancerMember http://172.28.200.101:8010 route=cluster1 retry=1 acquire=3000 timeout=10000 Keepalive=On
    BalancerMember http://172.28.200.101:8011 route=cluster2 retry=1 acquire=3000 timeout=10000 Keepalive=On
    
    ProxySet stickysession=ROUTEID
    ProxySet lbmethod=byrequests
  </Proxy>
  
  ProxyPassMatch ^/$          balancer://cluster
  ProxyPassMatch /health      balancer://cluster
  ProxyPassMatch /api/(.*)    balancer://cluster
  ProxyPassMatch /(.*\.jsp.*) balancer://cluster
</VirtualHost>
```
#### 5) systemd 등록
/etc/systemd/system/apache.service

```shell
[Unit]
Description=apache httpd 2.4.58
After=network.target syslog.target

[Service]
Type=forking
User=root
Group=root
ExecStart=/engn/apache/bin/apachectl start
ExecStop=/engn/apache/bin/apachectl graceful-stop
Restart=no

[Install]
WantedBy=multi-user.target
```

#### 5) weblogic-connector
```apacheconf
LoadModule weblogic_module modules/mod_wl_24.so

<IfModule mod_weblogic.c>
  WebLogicCluster IP:PORT,IP:PORT,IP:PORT
  ConnectTimeoutSecs 8
  ConnectRetrySecs 2
  Idempotent OFF
  DynamicServerList OFF
  MatchExpression *
  KeepAliveEnabled OFF
</IfModule>

<Location /api >
  WLSRequest On
  #SetHandler weblogic-handler
  WebLogicCluster IP:PORT,IP:PORT,IP:PORT
  #Idempotent OFF
</Location>
```

#### 6) selinux
```shell
$ chcon -Rt httpd_log_t /log/apache
$ chcon -Rt httpd_sys_content_t /sorc/memo
$ setsebool -P httpd_can_network_connect on
```


## `Ⅱ. 인증서`
### 1. openssl 인증서 생성

```shell
#!/bin/bash

DOMAIN=$1
FILENM=star.${DOMAIN}

cat <<- EOF > ${FILENM}.cnf
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
countryName             = KR
stateOrProvinceName     = Seoul
localityName            = Seonyudo
organizationName        = MK
organizationalUnitName  = Dev.Team
CN                      = ${DOMAIN}
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = *.${DOMAIN}
EOF

# crt 생성
# openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout ${FILENM}.key -out ${FILENM}.crt -sha256 -config ${FILENM}.cnf
openssl req -x509 \
  -nodes \
  -days 730 \
  -newkey rsa:2048 \
  -keyout ${FILENM}.key \
  -out ${FILENM}.crt \
  -sha256 \
  -config ${FILENM}.cnf

# ---
# 참고1) 실행 및 확인
$ ./create-crt.sh develop.net
$ ls -al *develop.net*

# 참고2) crt to pfx 변환
# DOMAIN=develop.net
# FILENM=star.${DOMAIN}
# openssl pkcs12 -export -in ${FILENM}.crt -inkey ${FILENM}.key -out ${FILENM}.pfx
$ openssl pkcs12 -export \
    -in star.develop.net.crt \
    -inkey star.develop.net.key \
    -out star.develop.net.pfx

# 참고3) pfx to jks 변환
# keytool -importkeystore -srckeystore ${FILENM}.pfx -srcstoretype pkcs12 -destkeystore ${FILENM}.jks -deststoretype jks
$ keytool -importkeystore \
    -srckeystore star.develop.net.pfx \
    -srcstoretype pkcs12 \
    -destkeystore star.develop.net.jks \
    -deststoretype jks
```

### 2. keytool 인증서 생성
java 에 포함된 keytool 은 keystore 기반으로 인증서와 키를 관리할 수 있습니다.

```shell
# private-key(mgkim.net.jks 파일) 생성
$ keytool -genkeypair \
    -keyalg RSA \
    -dname "CN=mgkim.net, OU=API Development, O=mgkim.net, L=Seoul, C=KR" \
    -keypass "dev1234" \
    -storepass "dev1234" \
    -keystore "mgkim.net.jks"
---
다음에 대해 유효 기간이 90일인 2,048비트 RSA 키 쌍 및 자체 서명된 인증서(SHA256withRSA)를 생성하는 중
        : CN=mgkim.net, OU=API Development, O=mgkim.net, L=Seoul, C=KR

# 인증서 파일(mgkim.net.cer 파일) 생성
$ keytool -export \
    -keystore "mgkim.net.jks" \
    -rfc \
    -file "mgkim.net.cer"
---
키 저장소 비밀번호 입력:  dev1234
인증서가 <mgkim.net.cer> 파일에 저장되었습니다.

# public-key(mgkim.net.jks.pub 파일) 생성
$ keytool -import \
    -file "mgkim.net.cer" \
    -keystore "mgkim.net.jks.pub"
---
키 저장소 비밀번호 입력:  dev1234
새 비밀번호 다시 입력: dev1234
소유자: CN=mgkim.net, OU=API Development, O=mgkim.net, L=Seoul, C=KR
발행자: CN=mgkim.net, OU=API Development, O=mgkim.net, L=Seoul, C=KR
...

이 인증서를 신뢰합니까? [아니오]:  y
인증서가 키 저장소에 추가되었습니다.
```


## `Ⅲ. tomcat`

### 1. 다운로드
```shell
$ wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.96/bin/apache-tomcat-8.5.96.tar.gz
```

### 2. 디렉토리 구조
```
servers/
└── smpl
    ├── conf
    │    ├── Catalina
    │    │    └── localhost
    │    │         └── ROOT.xml
    │    ├── catalina.policy
    │    ├── catalina.properties
    │    ├── context.xml
    │    ├── jaspic-providers.xml
    │    ├── jaspic-providers.xsd
    │    ├── server.xml
    │    ├── star.develop.net.jks
    │    └── web.xml
    ├── lib
    │    ├── ojdbc8-19.21.0.0.jar
    │    └── tomcat-8.5-ext.jar
    ├── restart-smpl.sh
    ├── start-smpl.sh
    ├── stop-smpl.sh
    ├── webapps
    └── work
tomcat/
└── tomcat-8.5.96
    ├── bin
    ├── conf
    ├── lib
    ├── logs
    ├── temp
    ├── webapps
    └── work
scouter/
├── agent.host
│   ├── conf
│   │   └── scouter.conf
│   ├── host.sh
│   ├── lib
│   ├── logs
│   ├── readlink.sh
│   ├── scouter.host.jar
│   └── stop.sh
└── agent.java
    ├── conf
    │    └── scouter.conf
    ├── dump
    ├── plugin
    ├── scouter-agent-java-2.20.0.jar
    └── scouter.agent.jar
```

### 3. 스크립트
#### 1) start-smpl.sh 
```shell
#!/bin/bash

BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

INSTANCE_ID="smpl"
EXEC_USER="smpl"
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.392.b08-4.el8_8.x86_64
CATALINA_HOME=/engn/tomcat/tomcat-8.5.96
LOG_BASE="/logs/${INSTANCE_ID}"

PATH=$JAVA_HOME/bin:$PATH

if [ ! -e $LOG_BASE ]; then
  mkdir -p $LOG_BASE
fi

CATALINA_BASE=$BASE_DIR
CATALINA_TMPDIR=$CATALINA_HOME/temp
CATALINA_OUT="${LOG_BASE}/${INSTANCE_ID}-tomcat_console.log"

echo "tomcat starting"

if [ `whoami` != "${EXEC_USER}" ]; then
  echo "please execute \"${EXEC_USER}\""
  exit 1
fi

pid=$( ps -ef | grep "instance.id=${INSTANCE_ID} " | grep -v grep | awk '{print $2}' )
if [ ! -z "$pid" ]; then
  echo "tomcat already running. please check pid \"${pid}\""
  exit 1
fi

SCOUTER_AGENT_DIR=/engn/scouter/agent.java
JAVA_OPTS="-server"
JAVA_OPTS="${JAVA_OPTS} -Xms512m -Xmx512m"
JAVA_OPTS="${JAVA_OPTS} -verbose:gc"
JAVA_OPTS="${JAVA_OPTS} -Xloggc:${LOG_BASE}/gc/`date +%Y%m%d_%H%M%S`-gc.log"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCDetails"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintGCDateStamps"
JAVA_OPTS="${JAVA_OPTS} -XX:+PrintHeapAtGC"
JAVA_OPTS="${JAVA_OPTS} -XX:+UseGCLogFileRotation"
JAVA_OPTS="${JAVA_OPTS} -XX:+ExitOnOutOfMemoryError"
JAVA_OPTS="${JAVA_OPTS} -XX:+HeapDumpOnOutOfMemoryError"
JAVA_OPTS="${JAVA_OPTS} -XX:HeapDumpPath=${LOG_BASE}/dump_${INSTANCE_ID}_'date+%Y%m%d_%H%M%S'.hprof"
JAVA_OPTS="${JAVA_OPTS} -XX:+DisableExplicitGC"
JAVA_OPTS="${JAVA_OPTS} -Dinstance.id=${INSTANCE_ID}"
JAVA_OPTS="${JAVA_OPTS} -Dlog.base=${LOG_BASE}"
JAVA_OPTS="${JAVA_OPTS} -Dfile.encoding=utf-8"
JAVA_OPTS="${JAVA_OPTS} -Djava.library.path=${BASE_DIR}/lib"
JAVA_OPTS="${JAVA_OPTS} -Doracle.jdbc.autoCommitSpecCompliant=false"
JAVA_OPTS="${JAVA_OPTS} -javaagent:${SCOUTER_AGENT_DIR}/scouter.agent.jar"
JAVA_OPTS="${JAVA_OPTS} -Dscuter.config=${SCOUTER_AGENT_DIR}/conf/scouter.conf"
JAVA_OPTS="${JAVA_OPTS} -Dobj_name=${INSTANCE_ID}_1"
JAVA_OPTS="${JAVA_OPTS} -Djava.net.preferIPv4Stack=true"

source ${CATALINA_HOME}/bin/catalina.sh start "$@"
```

#### 2) stop-smpl.sh 
```shell
#!/bin/bash
  
BASE_DIR=$( cd $( dirname $0 ) && pwd -P )

INSTANCE_ID="smpl"
EXEC_USER="tomcat"
JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.392.b08-4.el8_8.x86_64
CATALINA_HOME=/engn/tomcat/tomcat-8.5.96

PATH=$JAVA_HOME/bin:$PATH

CATALINA_BASE=$BASE_DIR

echo "tomcat stopping"

pid=$( ps -ef | grep "instance.id=${INSTANCE_ID} " | grep -v grep | awk '{print $2}' )
if [ -z "$pid" ]; then
  echo "tomcat is not running."
  exit 1
fi

source ${CATALINA_HOME}/bin/catalina.sh stop "$@"

for i in {1..1}; do
  printf "."
  pid=$( ps -ef | grep "instance.id=${INSTANCE_ID} " | grep -v grep | awk '{print $2}' )
  if [ "${pid}" != "" ]; then
    sleep 1
  else
    break
  fi
done
printf $'\n'

if [ "${pid}" != "" ]; then
  kill -15 "${pid}"
fi

echo "tomcat stopped"
```

### 4. 설정

#### 1) conf/server.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8015" shutdown="SHUTDOWN"><!-- default-port: 8005 -->
  <Listener className="org.apache.catalina.startup.VersionLoggerListener" />
  <Listener className="org.apache.catalina.core.AprLifecycleListener" SSLEngine="on" />
  <Listener className="org.apache.catalina.core.JreMemoryLeakPreventionListener" />
  <Listener className="org.apache.catalina.mbeans.GlobalResourcesLifecycleListener" />
  <Listener className="org.apache.catalina.core.ThreadLocalLeakPreventionListener" />

  <GlobalNamingResources>
    <Resource name="UserDatabase" auth="Container"
              type="org.apache.catalina.UserDatabase"
              description="User database that can be updated and saved"
              factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
              pathname="conf/tomcat-users.xml" />
    <Resource name="oracle/smplDS" type="javax.sql.DataSource" auth="Container" url="jdbc:oracle:thin:@172.28.200.31:1521:ORCLCDB"
              driverClassName="oracle.jdbc.driver.OracleDriver" username="SYSTEM" password="1"
              factory="org.apache.tomcat.jdbc.pool.DataSourceFactory"
              maxTotal="10" maxIdle="10" initialSize="10" maxWait="3000"
              validationQuery="SELECT 1 FROM DUAL" testOnBorrow="true" testOnConnect="true" testWhileIdle="true" logAbandoned="true" logValidationErrors="true" />
  </GlobalNamingResources>

  <Service name="Catalina">
    <Executor name="tomcatThreadPool" namePrefix="catalina-exec-" maxThreads="150" minSpareThreads="4"/>
    <!-- default-port: 8080 -->
    <Connector port="8010" protocol="HTTP/1.1" connectionTimeout="20000" redirectPort="8443" 
               server=""
               maxParameterCount="-1" maxPostSize="-1" 
               relaxedQueryChars="[]|{}^&#x5c;&#x60;&quot;&lt;&gt;" />
    <Connector protocol="org.apache.coyote.http11.Http11NioProtocol" port="8443" maxThread="150" SSLEnabled="true">
      <SSLHostConfig>
        <Certificate certificateKeystoreFile="conf/star.develop.net.jks" type="RSA" certificateKeystorePassword="dev1234" />
      </SSLHostConfig>
    </Connector>
    <Engine name="Catalina" defaultHost="localhost" jvmRoute="worker1">
      <Realm className="org.apache.catalina.realm.LockOutRealm">
        <Realm className="org.apache.catalina.realm.UserDatabaseRealm" resourceName="UserDatabase" />
      </Realm>
      
      <!-- cluster -->
      <!-- default-port: 4000 -->
      <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster" channelSendOptions="8" channelStartOptions="3">
        <Manager className="org.apache.catalina.ha.session.DeltaManager" expireSessionsOnShutdown="false" notifyListenersOnReplication="true" />
        <Channel className="org.apache.catalina.tribes.group.GroupChannel">
          <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
            <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender" />
          </Sender>
          <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                    address="127.0.0.1" port="4010" autoBind="0" maxThreads="6" selectorTimeout="5000" />
          <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpPingInterceptor" staticOnly="true" />
          <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector" />
          <Interceptor className="org.apache.catalina.tribes.group.interceptors.StaticMembershipInterceptor">
            <Member className="org.apache.catalina.tribes.membership.StaticMember" 
                    host="127.0.0.1" port="4011" uniqueId="{0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2}" />
          </Interceptor>
          <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatchInterceptor" />
        </Channel>
        <Valve className="org.apache.catalina.ha.tcp.ReplicationValve" filter=".*\.gif;.*\.js;.*\.jpg;.*\.png;.*\.htm;.*\.html;.*\.css;.*\.txt;" />
        <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener" />
      </Cluster>
      <!-- //cluster -->

      <Host name="localhost"  appBase="webapps" unpackWARs="false" autoDeploy="false">
        <Valve className="org.apache.catalina.valves.AccessLogValve" 
               rotatable="false" directory="${log.base}" prefix="${instance.id}-tomcat_access" suffix=".log"
               pattern="%{X-Forwarded-For}i %h %l %u %t &quot;%r&quot; %s %b" />
        <Valve className="org.apache.catalina.valves.HealthCheckValve" path="/health" checkContainersAvailable="true" />
      </Host>
    </Engine>
  </Service>
</Server>
```

#### 2) conf/context.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<Context>
  <WatchedResource>WEB-INF/web.xml</WatchedResource>
  <WatchedResource>${catalina.base}/conf/web.xml</WatchedResource>
  
  <ResourceLink global="oracle/smplDS" name="oracle/smplDS" type="javax.sql.DataSource" />
  
</Context>
```

#### 3) conf/Catalina/localhost/ROOT.xml
```xml
<?xml version="1.0" encoding="utf-8"?>
<Context path="" docBase="/sorc/smpl/war" reloadable="false">
</Context>
```

### 5. 기타
#### 1) alias
```shell
alias cdwas='cd /engn/servers/smpl'
alias cdapp='cd /sorc/smpl'
alias cdlog='cd /logs/smpl'
alias tailwas='tail -f /logs/smpl/smpl-tomcat_console.log'
alias viwas='vi /logs/smpl/smpl-tomcat_console.log'
alias tailacc='tail -f /logs/smpl/smpl-tomcat_access.log'
alias curlwas='curl -X GET http://localhost:8010/'
alias pswas='ps -ef | grep java | grep "instance.id=smpl "'
```

#### 2) config-list.sh
```shell
#!/bin/bash

INSTANCE_BASE='/engn/servers'
LIST=($(ls /engn/servers))

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
---
[tomcat] basic 
      inst  shut  http             cIp cPort             mIp mPort                                mId
------------------------------------------------------------------------------------------------------
      smpl  8015  8010       127.0.0.1  4010       127.0.0.1  4011  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,2}
    smpl_2  8016  8011       127.0.0.1  4011       127.0.0.1  4010  {0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1}

[tomcat] jndi 
      inst            jndi     username url
------------------------------------------------------------------------------------------------------
      smpl   oracle/smplDS       SYSTEM jdbc:oracle:thin:@172.28.200.31:1521:ORCLCDB
    smpl_2   oracle/smplDS       SYSTEM jdbc:oracle:thin:@172.28.200.31:1521:ORCLCDB
```
