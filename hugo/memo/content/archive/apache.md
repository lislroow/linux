## 1. 설치

### 1) 다운로드

다운로드 후 tar zxvf *.tar.gz 로 압축 해제 합니다.

```
$ wget https://dlcdn.apache.org/httpd/httpd-2.4.58.tar.gz
$ wget https://dlcdn.apache.org/apr/apr-1.7.4.tar.gz
$ wget https://dlcdn.apache.org/apr/apr-util-1.6.3.tar.gz
$ wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz
```

### 2) compile 설치

```
$ cd /opt/apache/apr-1.7.4 && \
  ./configure --prefix=/usr/local/src/apr-1.7.4 && \
  make && \
  make install
$ cd /opt/apache/apr-util-1.6.3 && \
  ./configure --prefix=/usr/local/src/apr-util-1.6.3 \
    --with-apr=/usr/local/src/apr-1.7.4 && \
  make && \
  make install
$ cd /opt/apache/pcre2-10.42 && \
  ./configure --prefix=/usr/local/src/pcre2-10.42 \
    --with-apr=/usr/local/src/apr-1.7.4 && \
  make && \
  make install
$ cd /opt/apache/httpd-2.4.58 && \
  ./configure --prefix=/engn/apache \
    --enable-modules=most \
    --enable-mods-shared=all \
    --enable-so --with-mpm=prefork \
    --with-apr=/usr/local/src/apr-1.7.4 \
    --with-apr-util=/usr/local/src/apr-util-1.6.3 \
    --with-pcre=/usr/local/src/pcre2-10.42 && \
  make && \
  make install
```

## 2. 설정

### 1) 기본 항목

- User, Group 설정: `User apache`, `Group apache`
- 디렉토리 설정: `DocumentRoot`, `<Directory>`, `<Location>`
  ```
  DocumentRoot "/sorc/apache"
  <Directory />
    #AllowOverride none
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
  ```
  LogFormat "%{X-Forward-For}i %h %l %u %t \"%r\" %>s %b \"%{Referer}i\" %I %O" combinedio
  ```
- 서버 정보 노출: `ServerTokens Prod`, `ServerSignature Off`
  - Prod: 웹서버의 이름만 표시 (Full 은 전체 표시)

### 2) 성능 및 옵션

- mpm 설정: `mpm_prefork_module`
  ```
  <IfModule mpm_prefork_module>
    ServerLimit           1024
    StartServers             5
    MinSpareServers          5
    MaxSpareServers         10
    MaxRequestWorkers     1024
    MaxConnectionsPerChild   0
  </IfModule>
  ```
- request body 크기 제한 설정: `LimitRequestBody`
- mod_status, mod_info 설정
  ```
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

### 3) 가상호스트 및 proxy 설정

```
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








