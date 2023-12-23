
mvn dependency:copy -Dartifact=com.oracle.database.jdbc:ojdbc8:19.21.0.0:jar -DoutputDirectory=/c

## [2023.12.15] apache compile 설치

mkdir -p /opt/apache
cd /opt/apache
wget https://dlcdn.apache.org/httpd/httpd-2.4.58.tar.gz
wget https://dlcdn.apache.org/apr/apr-1.7.4.tar.gz
wget https://dlcdn.apache.org/apr/apr-util-1.6.3.tar.gz
wget https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz

cd /opt/apache/apr-1.7.4 && ./configure --prefix=/usr/local/src/apr-1.7.4 && make && make install
cd /opt/apache/apr-util-1.6.3 && ./configure --prefix=/usr/local/src/apr-util-1.6.3 --with-apr=/usr/local/src/apr-1.7.4 && make && make install
cd /opt/apache/pcre2-10.42 && ./configure --prefix=/usr/local/src/pcre2-10.42 --with-apr=/usr/local/src/apr-1.7.4 && make && make install
cd /opt/apache/httpd-2.4.58 && ./configure --prefix=/engn/apache --enable-modules=most --enable-mods-shared=all --enable-so --with-mpm=prefork --with-apr=/usr/local/src/apr-1.7.4 --with-apr-util=/usr/local/src/apr-util-1.6.3 --with-pcre=/usr/local/src/pcre2-10.42 && make && make install


## [유틸리티]
yum install -y nmap-ncat.x86_64 tree

## [계정]
groupadd wasadm
useradd -g wasadm smpl

## tomcat clustering 로그

- [1-active / 2-shutdown] 
Dec 17, 2023 9:18:18 PM org.apache.catalina.ha.tcp.SimpleTcpCluster memberDisappeared
INFO: Received member disappeared:[org.apache.catalina.tribes.membership.StaticMember[tcp://127.0.0.1:4011,127.0.0.1,4011, alive=0, securePort=-1, UDP Port=-1, id={0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 }, payload={}, command={}, domain={}]]

- [1-active / 2-start]
Dec 17, 2023 9:18:33 PM org.apache.catalina.ha.tcp.SimpleTcpCluster memberAdded
INFO: Replication member added:[org.apache.catalina.tribes.membership.StaticMember[tcp://127.0.0.1:4011,127.0.0.1,4011, alive=0, securePort=-1, UDP Port=-1, id={0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 }, payload={}, command={}, domain={}]]
Dec 17, 2023 9:18:33 PM org.apache.catalina.tribes.group.interceptors.TcpFailureDetector performBasicCheck
INFO: Suspect member, confirmed alive.[org.apache.catalina.tribes.membership.StaticMember[tcp://127.0.0.1:4011,127.0.0.1,4011, alive=0, securePort=-1, UDP Port=-1, id={0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 }, payload={}, command={}, domain={}]]


org.apache.catalina.tribes.transport.ReceiverBase bind
