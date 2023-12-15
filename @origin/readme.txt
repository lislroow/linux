
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
