## Ⅰ. apache

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

#### 5) weblogic-connector
```
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


## Ⅱ. 인증서
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


## Ⅲ. tomcat

### 1. 다운로드

```shell
$ wget https://archive.apache.org/dist/tomcat/tomcat-8/v8.5.96/bin/apache-tomcat-8.5.96.tar.gz
```
