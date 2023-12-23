
#### (centos) hostname

```
[root@develop ~]$ hostnamectl set-hostname develop
[root@develop ~]$
```

#### (tar) -I, --use-compress-program

```
$ tar -I zstd -xvf zsh-5.8-5-x86_64.pkg.tar.zst
```

#### (centos) xargs

```
# 공백이나 개행문자가 포함된 파일명 삭제
$ fine . -type -f -print0 | xargs -O /bin/rm -f
$ ls *.txt | xargs cat >> abc.txt
$ ls | grep *.bak | xargs -I{} cp {} /home/bak_file
```


#### (centos) lsof

```
$ lsof -u jenkins -a +D /data
$ lsof -i 4
$ lsof -t -i TCP:8100
$ ps -ef | grep `lsof -t -i tcp:8100`
$ lsof -t -i tcp:8100 | xargs kill -9 
```

#### (systemctl) Requires 속성

logstash 서비스를 elasticsearch 서비스의 종속으로 구성해야할 필요가 생겼습니다.

```
$ vi /etc/systemd/system/logstash.service
[Unit]
Description=logstash
Requires=elasticsearch.service

# 종속성 확인
$ systemctl list-dependencies logstash.service 
logstash.service
● ├─-.mount
● ├─elasticsearch.service
● ├─system.slice
● └─sysinit.target
●   ├─dev-hugepages.mount
●   ├─dev-mqueue.mount
``` 

#### (dnf-makecache) 오류

`dnf-makecache`는 centos의 자동업데이트 기능입니다.

`오류: repo 'appstream': Cannot prepare internal mirrorlist: No URLs in mirrorlist 를 위해 메타데이타 내려받기에 실패하였습니다`

disable 명령어는 다음과 같습니다.

```
$ gsettings set org.gnome.software download-updates false
$ systemctl disable dnf-makecache.service
$ systemctl disable dnf-makecache.timer
```

정상 작동하도록 하기 위해 yum 저장소 설정 파일을 수정합니다.

```
$ sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Linux-*
$ sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-Linux-*
```

#### (shell) script 정보

bash 에서 script 파일을 실행할 때 기본 정보를 출력했습니다.

```
#!/bin/bash

echo
echo "# arguments called with ---->  ${@}     "
echo "# \$1 ---------------------->  $1       "
echo "# \$2 ---------------------->  $2       "
echo "# path to me --------------->  ${0}     "
echo "# parent path -------------->  ${0%/*}  "
echo "# my name ------------------>  ${0##*/} "
echo
exit


$ /z/project/pilot/service/service-www/a.sh 1 2 4

# arguments called with ---->  1 2 4
# $1 ---------------------->  1
# $2 ---------------------->  2
# path to me --------------->  /z/project/pilot/service/service-www/a.sh
# parent path -------------->  /z/project/pilot/service/service-www
# my name ------------------>  a.sh
```

#### (libxml2) xmllint

xmllint 를 이용하여 nexus 의 maven-metadata.xml 을 파싱하는 예시입니다.

```
$ XML_URL="https://nexus/repository/maven-snapshot/mgkim/framework/framework-online/maven-metadata.xml"
$ curl -s ${XML_URL} | cat -
<?xml version="1.0" encoding="UTF-8"?>
<metadata>
  <groupId>mgkim.framework</groupId>
  <artifactId>framework-online</artifactId>
  <versioning>
    <versions>
      <version>1.0-SNAPSHOT</version>
      <version>2.0-SNAPSHOT</version>
    </versions>
    <lastUpdated>20220110062815</lastUpdated>
  </versioning>
</metadata>
# --xpath 에 존재하지 않는 node 명을 입력했을 경우 'XPath set is empty' 가 표시됨
$ echo $(curl -s ${XML_URL} | xmllint --xpath "//aaa/text()" -)
XPath set is empty
# node명 "<groupId>" 의 값을 가져오는 2가지 예시
$ echo $(curl -s ${XML_URL} | xmllint --xpath "metadata/groupId/text()" -)
mgkim.framework
$ echo $(curl -s ${XML_URL} | xmllint --xpath "//groupId/text()" -)
mgkim.framework
# node명 "<version>" 이 여러개일 경우 마지막만 반환하는 예시
$ echo $(curl -s ${XML_URL} | xmllint --xpath "//version[last()]/text()" -) 
2.0-SNAPSHOT
# curl 의 결과를 xmllint 에 전달하기 위해 
# xmllint 의 마지막에 dash`-` 문자가 반드시 포함되어야 함
```

`--xpath` 는 쌍따옴표`"`로 해주세요. (`'`일 경우 변수를 포함한 값으로 표현이 안됩니다.)

아래는 여러 node 가 select 되는 예시에서 index 변수로 접근하는 예시입니다.

```
$ XML_URL="https://nexus/repository/maven-snapshot/mgkim/framework/framework-online/maven-metadata.xml"
$ curl -s ${XML_URL} | cat -
<?xml version="1.0" encoding="UTF-8"?>
<metadata>
  <groupId>mgkim.framework</groupId>
  <artifactId>framework-online</artifactId>
  <versioning>
    <versions>
      <version>1.0-SNAPSHOT</version>
      <version>2.0-SNAPSHOT</version>
    </versions>
    <lastUpdated>20220110062815</lastUpdated>
  </versioning>
</metadata>
$ count=$(curl -s ${XML_URL} | xmllint --xpath "count(//version)" -)
$ echo "count=${count}"
count=2
$ for ((i=1; i<=${count}; i++)); do
  # --xpath '//version[$i]/text()' 일 경우
  # "XPath error : Undefined variable" 오류가 발생합니다.
  echo $(curl -s ${XML_URL} | xmllint --xpath "//version[$i]/text()" -)
done
1.0-SNAPSHOT
2.0-SNAPSHOT
```

xmllint 는 libxml2 패키지에 포함되어 있습니다.

```
$ yum provides xmllint
마지막 메타자료 만료확인 17:42:56 이전인: 2022년 01월 11일 (화) 오후 04시 01분 22초.
libxml2-2.9.7-9.el8_4.2.x86_64 : Library providing XML and HTML support
리포지토리      : baseos
일치하는 항목 :
파일 이름 : /usr/bin/xmllint
```

#### (vim) .vimrc

`vi ~/.vimrc` 로 아래 기본 설정을 등록합니다.

.vimrc 에는 # 주석이 오류를 일으키니 설정 시 제거해야 합니다.

```
$ vi ~/.vimrc
if has("syntax")
  syntax on
endif

set paste

# / 검색 강조
set hlsearch

# 자동 들여쓰기
set autoindent
set cindent

# tab 설정
set ts=2
set sts=2
set shiftwidth=2

# 커서 위 괄호 강조
set showmatch

# 줄번호와 행번호 표시
set ruler
```

#### (self-signed-cert) git-bash 등록

git-bash 에서 curl 을 사용할 때 ssl 인증 문제가 발생할 경우입니다.

```
$ curl https://nexus/repository/maven-release/mgkim/service/service-www/maven-metadata.xml
curl: (60) SSL certificate problem: self signed certificate
More details here: https://curl.se/docs/sslcerts.html

curl failed to verify the legitimacy of the server and therefore could not
establish a secure connection to it. To learn more about this situation and
how to fix it, please visit the web page mentioned above.
```

해당 사이트(`https://nexus/`)의 crt 파일을 저장하고 git-bash 에서 관리하는 ca-bundle.crt 의 끝부분에 내용을 추가합니다.

파일 경로: `C:\Program Files\Git\mingw64\ssl\certs\ca-bundle.crt`

#### (self-signed-cert) java 등록

로컬 설치된 java 에 인증서 파일(*.crt) 등록을 하기 위해서는 $JAVA_HOME/bin/keytool 를 사용해야 합니다.

ca 에 등록되지 않은 인증서로 https 통신을 하는 경우에는 ssl-handshake 과정에서 오류가 발생하므로

해당 사이트의 인증서를 로컬 java 에 신뢰할 수 있는 인증서에 등록해야 합니다.

아래는 `hello.crt` 라는 인증서를 등록하는 예시입니다.

```
# 인증서 등록
# oracle java8 에서 cacerts 파일 위치
# CACERTS=$JAVA_HOME/jre/lib/security/cacerts
# temurin java11 에서 cacerts 파일 위치
$ CACERTS=$JAVA_HOME/lib/security/cacerts
$ keytool -importcert -keystore $CACERTS -file "hello.crt" -alias "hello"
키 저장소 비밀번호 입력: (changeit 입력)
이 인증서를 신뢰합니까? [아니오]:  (y 입력)
인증서가 키 저장소에 추가되었습니다.

# 인증서 조회
$ keytool -list -keystore $CACERTS | grep "hello"
키 저장소 비밀번호 입력: (changeit 입력)
hello, 2020. 5. 8, trustedCertEntry,

# 인증서 삭제
$ keytool -delete -alias "hello" -keystore $CACERTS
```

nexus 를 https 로 서비스 중인 상태에서 java에 인증서를 등록하지 않았을 경우 아래와 같은 오류가 발생합니다.

```
Transfer failed for http://nexus/repository/maven-snapshot/mgkim/service/service-www/2.0-SNAPSHOT/maven-metadata.xml: 
PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target -> [Help 1]
```

jenkins 에서 빌드 시 오류가 발생하여 java 에 인증서를 추가합니다.

```
$ CACERTS=$JAVA_HOME/lib/security/cacerts
$ keytool -importcert -keystore $CACERTS -file /z/nexus.crt -alias 'nexus'

### `키 저장소 비밀번호` 에는 changeit 으로 입력해야 합니다. ###
$ keytool -importcert -keystore $CACERTS -file /etc/httpd/conf.d/certs/nexus.crt -alias 'nexus'
경고: -cacerts 옵션을 사용하여 cacerts 키 저장소에 액세스하십시오.
키 저장소 비밀번호 입력:  
소유자: CN=nexus, OU=Dev Team, O=SPACESOFT, L=Seonyudo, ST=Seoul, C=KR
발행자: CN=nexus, OU=Dev Team, O=SPACESOFT, L=Seonyudo, ST=Seoul, C=KR
일련 번호: 7aa1637941794c08365e9f9a3c531189b87f0b5e
적합한 시작 날짜: Mon Jan 10 12:15:12 KST 2022 종료 날짜: Wed Jan 10 12:15:12 KST 2024
인증서 지문:
   SHA1: D4:A6:92:2A:0C:97:1F:56:93:03:EC:8C:50:B3:27:5D:51:BD:30:63
   SHA256: 62:BA:47:E9:3F:A6:A7:7D:78:99:87:E1:9B:E7:23:D5:B6:6B:2A:CC:5E:D9:BF:4A:DB:95:AD:67:47:70:86:96
서명 알고리즘 이름: SHA256withRSA
주체 공용 키 알고리즘: 2048비트 RSA 키
버전: 3

확장: 

#1: ObjectId: 2.5.29.37 Criticality=false
ExtendedKeyUsages [
  serverAuth
]

#2: ObjectId: 2.5.29.15 Criticality=true
KeyUsage [
  DigitalSignature
  Key_Agreement
]

#3: ObjectId: 2.5.29.17 Criticality=false
SubjectAlternativeName [
  DNSName: nexus
]

이 인증서를 신뢰합니까? [아니오]:  y
인증서가 키 저장소에 추가되었습니다.
$ 
```

#### (self-signed-cert) centos 등록

- `/etc/pki/ca-trust/source/anchors/` 경로에 crt 파일을 복사
- `update-ca-trust extract` 실행으로 신뢰할 수 있는 인증서를 추가

```
$ cp /etc/httpd/conf.d/certs/nexus.crt /etc/pki/ca-trust/source/anchors/
$ update-ca-trust extract
```

`update-ca-trust` 명령으로 등록이 안될 경우 직접 추가하는 방법입니다.

`/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem` 파일에 crt 파일의 내용을 직접 추가합니다.

```
$ chmod u+w /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
$ cat nexus.crt >> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
$ chmod u-w /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
```

#### (shell) script 파일 디렉토리

`/project/script/build.sh` 파일이 실행될 때 현재 디렉토리`/project/script/`를 확인하는 방법입니다.

maven 프로젝트의 build.sh 파일이 pom.xml 과 같은 디렉토리가 아닐 경우 활용할 수 있습니다.

```
# build.sh 가 존재하는 디렉토리를 반환합니다.
$ DIR="$( cd $( dirname "$0" ) && pwd -P )"
$ echo "${DIR}"
/home/user/

# build.sh 의 parent 디렉토리를 반환합니다.
$ DIR="$( cd $( dirname "$0" )/.. && pwd -P )"
$ echo "${DIR}"
/home
```

#### (shell) find newer samefile

오래된 파일을 찾을 경우, 기준이되는 파일은 제외하는 예시입니다.

```
# 기준이 되는 파일을 생성 (e.g 1981년 07월 19일)
$ touch -t 198107190000.00 a.txt
$ ls -al a.txt     # alias ls='ls --time-style long-iso ' 일 경우 시각까지 표시됨
-rw-r--r-- 1 root root 0 1981-07-19 00:00 a.txt

# 기준보다 오래된 파일 생성
$ touch -t 198101010000 old.txt
$ ls -al old.txt 
-rw-r--r-- 1 root root 0 1981-01-01 00:00 old.txt

# find 검색 (a.txt 파일보다 오래된 파일을 찾음)
$ find . -maxdepth 1 -type f ! -newer a.txt -name '*.txt'
./a.txt
./old.txt

# find 검색 (기준이 되는 파일을 제외하고 찾음)
# -samefile 혹은 -name 해도됨
$ find . -maxdepth 1 -type f ! -newer a.txt -name '*.txt' ! -samefile a.txt
./old.txt
```

#### (shell) curl

curl 로 http_code 를 받아오는 예시 입니다.

이 예시는 was 가 정상 기동되었는지 확인하는데 활용할 수 있습니다.

```
$ curl --write-out "%{http_code}" --silent --output /dev/null "http://localhost:7100/"
200 # 서버가 기동되지 않은 상태이면 즉시 응답이 오며, http_code 는 000 가 반환됩니다.
```

#### (shell) 파일명 문자열

```
# 파일명에서 확장자 분리
$ FILE_NAME=service-www-2.0-SNAPSHOT.jar
$ echo ${FILE_NAME%.*}
service-www-2.0-SNAPSHOT
$ echo ${FILE_NAME##*.}
jar

# 파일경로에서 파일명
$ FILE_PATH=/app/WAS/pilot/service-www-2.0-SNAPSHOT.jar
$ echo ${FILE_PATH##*/}
service-www-2.0-SNAPSHOT.jar
```

#### (shell) while 문

```
PS_CMD="ps -ef | grep -v grep | egrep ${INST_ID}.*\\.jar | awk '{ print \$2 }'"
_PID=$(eval "${PS_CMD}")
# kill -15 실행
kill -15 $_PID

# 프로세스가 종료되었는지 while 문에서 확인
while [ $i -lt 600 ];
do
  _CHECK_PID=$(eval "${PS_CMD}")
  if [ "${_CHECK_PID}" == "" ]; then
    echo "${INST_ID}(pid:'${_PID}') killed"
    break
  fi
  i=$(( $i + 1 ))
done
```

#### (shell) for 문

배열을 생성하고 for 문으로 출력하는 예시 입니다.

```
SVR_LIST=(
  '172.28.200.20'
  '172.28.200.30'
)
echo "SVR_LIST=${SVR_LIST[*]}"

total=${#SVR_LIST[*]}
idx=0
for SVR in ${SVR_LIST[*]}
do
  idx=$(( $idx + 1 ))
  echo "[${idx}/${total}]SVR=${SVR}"
done
```

#### (shell) case 문

```
case $var in
  a*) # a로 시작하는 문자열일 경우
    ;;
  a?) # a뒤에 1개의 문자가 올 경우
    ;;
  a[bc]) # ab 혹은 ac 일 경우
    ;;
esac
```

#### (xmlstarlet) 

설치

```
$ dnf install epel-release
$ yum install xmlstarlet
```

사용법

```
xmlstarlet sel -N x="http://maven.apache.org/POM/4.0.0" -t -v "x:project/x:version" ./pom.xml
```

#### (firewall) disabled

추가된 목록: /etc/firewalld/zones/public.xml

서비스명: `firewalld`

#### (selinux) disabled

파일: /etc/selinux/config

```
SELINUX=disabled
```

적용: `shutdown -r now`

#### (network) ip 설정

파일: /etc/sysconfig/network-scripts/ifcfg-ens33 

```
BOOTPROTO="none"
IPV6INIT="no"
IPADDR="172.28.200.30"
PREFIX="24"
GATEWAY="172.28.200.2"
DNS1="8.8.8.8"
```

적용: `systemctl restart NetworkManager`

#### (openssl) key 생성 cmd

```
# 암호화하지 않은 개인키
$ openssl genrsa -out private_key.pem 2048

# 3des로 암호화된 개인키 생성
# passphrase를 입력이 필요합니다.
$ openssl genrsa -des3 -out enc_private_key.pem 2048

# 기존 개인키에 패스워드 추가
$ openssl rsa -des3 -in private_key.pem -out enc_private_key.pem

# 기존 개인키에 패스워드 제거
$ openssl rsa -in enc_private_key.pem -out private_key.pem
```

#### (tar) 분할 압축

```
# split
$ tar cvfz - target | split -b 3072m - target.tgz
$ cat target.tgz.* | tar zxvf -
```

#### (tar) exclude 설정

```
# exclude
$ cat .tarexclude
build.*
run.*
bin
.svn/*
.git/*
.project
.tarexclude
backup.sh
$ tar cvfz ../target.tgz * -X .tarexclude
```

#### (windows) xcopy

```
> xcopy /?
Copies files and directory trees.

  /D:m-d-y     Copies files changed on or after the specified date.
               If no date is given, copies only those files whose
               source time is newer than the destination time.
  /S           Copies directories and subdirectories except empty ones.
  /E           Copies directories and subdirectories, including empty ones.
               Same as /S /E. May be used to modify /T.
  /V           Verifies the size of each new file.
  /C           Continues copying even if errors occur.
  /I           If destination does not exist and copying more than one file,
               assumes that destination must be a directory.
  /Y           Suppresses prompting to confirm you want to overwrite an
               existing destination file.
  /J           Copies using unbuffered I/O. Recommended for very large files.
```

`xcopy E:\유틸리티\*.* D:\유틸리티 /d/i/s/c/y`


#### (maven) 패스워드 암호화

`settings.xml`에는 nexus 저장소에 deploy 를 할 때 아래와 같이 nexus 의 계정정보를 포함하고 있어야 합니다.

```
<servers>
  <server>
    <id>nexus-release</id>
    <username>admin</username>
    <password>패스워드</password>
  </server>
  <server>
    <id>nexus-snapshot</id>
    <username>admin</username>
    <password>패스워드</password>
  </server>
</servers>
```

패스워드를 암호화하여 설정하는 방법입니다. (`settings-security.xml` 파일은 로컬 저장소 .m2 디렉토리에 있어야 합니다.)

- `mvn -emp 마스터패스워드`명령으로 master 패스워드 문자열을 생성하고, `~/.m2/settings-security.xml` 파일을 아래와 같이 생성하고 저장합니다.
```
# "-emp" 는 "--encrypt-master-password" 입니다.
$ mvn -emp 마스터패스워드
{h/JmfOxXj2IH/whyc5/7wpvOT5AeBmlHV/nzmk7rzY+i7vEvpg46lHddfEwHFtN1}
$
$ cat << EOF > ~/.m2/settings-security.xml
<settingsSecurity>
  <master>{h/JmfOxXj2IH/whyc5/7wpvOT5AeBmlHV/nzmk7rzY+i7vEvpg46lHddfEwHFtN1}</master>
</settingsSecurity>
EOF
$ 
```

- `mvn -ep 패스워드`명령으로 nexus 의 계정에 해당되는 패스워드 문자열을 생성하고 `$M2_HOME/conf/settings.xml`의 `<password>`에 추가합니다.
```
$ mvn -ep 패스워드
{nvTOxUicu5EHTqNwVFkrSKjAQnANDMwZy6sCuPND00w=}
$ vi $M2_HOME/conf/settings.xml
<server>
  <id>nexus-snapshot</id>
  <username>admin</username>
  <password>{nvTOxUicu5EHTqNwVFkrSKjAQnANDMwZy6sCuPND00w=}</password>
</server>
```

#### (maven) deploy, release 관련 플러그인

spring-boot 를 배포할 때 의존성 라이브러리를 포함하여 executable-jar 파일을 생성하는 `spring-boot:repackage` 플러그인을 추가했습니다.

maven 기존 플러그인 maven-deploy-plugin 를 `nexus-staging-maven-plugin` 로 교체했습니다.

release 버전의 아티팩트를 nexus 에 배포하고 버전을 올려주는 기능을 위해 `maven-release-plugin` 설정을 했습니다.

```
<plugins>
  <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-deploy-plugin</artifactId>
    <configuration>
      <!-- nexus-staging-maven-plugin 로 인해 skip 설정을 해야 합니다. -->
      <skip>true</skip>
    </configuration>
  </plugin>
  <plugin>
    <groupId>org.sonatype.plugins</groupId>
    <artifactId>nexus-staging-maven-plugin</artifactId>
    <executions>
      <execution>
        <!-- default-deploy 에 추가합니다. -->
        <id>default-deploy</id>
        <phase>deploy</phase>
        <goals>
           <goal>deploy</goal>
        </goals>
      </execution>
    </executions>
    <configuration>
      <!-- nexus pro 버전에만 staging-repository 기능을 사용할 수 있습니다. -->
      <skipStaging>true</skipStaging>
    </configuration>
  </plugin>
  <plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <executions>
      <execution>
        <!-- default-install 에 추가합니다. -->
        <!-- deploy 을 실행하면 실행됩니다. -->
        <id>default-install</id>
        <phase>install</phase>
        <goals>
          <!-- spring-boot-maven-plugin 의 repackage 가 실행되도록 합니다. -->
          <goal>repackage</goal>
        </goals>
      </execution>
    </executions>
  </plugin>
  <plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-release-plugin</artifactId>
    <configuration>
      <autoVersionSubmodules>false</autoVersionSubmodules>
      <!-- release:perform 이 실행될 때 deploy 를 실행하여 -->
      <!-- spring-boot:repackage 까지 같이 실행되도록 합니다. -->
      <goals>deploy</goals>
      <scmCommentPrefix>[build]</scmCommentPrefix>
    </configuration>
  </plugin>
</plugins>
```

#### (maven) spring-boot:repackage

packaging 이 jar 인 프로젝트를 `mvn package` 으로 jar 를 생성한 다음에 `mvn spring-boot:repackage` 을 실행해야 합니다.

리패키징이되면 jar 아티팩트에 의존성으로 설정된 jar 파일들이 포함됩니다.

아래는 리패키징이 정상이면 볼 수 있는 로그 입니다.

```
[INFO] --- spring-boot-maven-plugin:2.6.1:repackage (default-cli) @ service-www ---
[INFO] Replacing main artifact with repackaged archive
```

#### (maven) help:evaluate 로컬 저장소 경로

mvn 명령으로 현재 설정된 로컬 저장소를 반환하는 goal 입니다.

```
$ mvn help:evaluate -Dexpression=settings.localRepository -q -DforceStdout
```

#### (maven) deploy:deploy-file 시 저장소 지정

pom.xml 에 포함되어있는 version 에 `-SNAPSHOT` 이 있으면 release 저장소에 deploy 할 수 없다는 오류가 발생하므로 주의가 필요합니다.

```
MVN_ARGS=""
MVN_ARGS="${MVN_ARGS} -DpomFile=${PROJECT_BASE}/pom.xml"
MVN_ARGS="${MVN_ARGS} -Dfile=${PROJECT_BASE}/target/${JAR_FILE}"

# jar 파일명에 "-SNAPSHOT" 이 있으면 snapshot 저장소에 deploy 되어야 합니다. 
if [[ "${JAR_FILE}" = *"-SNAPSHOT"* ]]; then
  MVN_ARGS="${MVN_ARGS} -DrepositoryId=maven-snapshot"
  MVN_ARGS="${MVN_ARGS} -Durl=http://nexus/repository/maven-snapshot/"
else
  MVN_ARGS="${MVN_ARGS} -DrepositoryId=maven-release"
  MVN_ARGS="${MVN_ARGS} -Durl=http://nexus/repository/maven-release/"
fi

mvn deploy:deploy-file $MVN_ARGS
```

#### (git) pull.ff only

`git config --global pull.ff only` 설정을 추가하면 됩니다.

```
$ git pull origin main
warning: Pulling without specifying how to reconcile divergent branches is
discouraged. You can squelch this message by running one of the following
commands sometime before your next pull:

  git config pull.rebase false  # merge (the default strategy)
  git config pull.rebase true   # rebase
  git config pull.ff only       # fast-forward only

You can replace "git config" with "git config --global" to set a default
preference for all repositories. You can also pass --rebase, --no-rebase,
or --ff-only on the command line to override the configured default per
invocation.
```

#### (git) turn off crlf warning

`warning: LF will be replaced by CRLF in` 메시지를 보고 싶지 않을 경우 아래 옵션을 추가합니다.

```
$ git config --global core.safecrlf false
```

#### (windows) setx

`cmd` 에서 아래 명령을 실행하면 `시스템 변수` 에 추가됩니다.

```
setx /m JAVA_HOME "D:\develop\java\openjdk-11.0.2"
```

#### (nexus) curl PUT

```
curl -u {id}:{passwd} -X PUT -v -T org/apache/poi/poi/3.10-FINAL/poi-3.10-FINAL.jar http://nexus/repository/maven-public-hosted/org/apache/poi/poi/3.10-FINAL/poi-3.10-FINAL.jar
```

#### (eclipse) xml editor: tab to space

xml editor 에서 `tab` 키 입력 시 `space` 가 입력되도록 변환하는 방법은 2가지를 설정해야 합니다.

- single-line: `General` > `Editors` > `Text Editors`: `Insert spaces for tabs` 체크
- multi-line: `XML` > `XML Files` > `Editor`: `Indent using spaces` 선택


#### (eclipse) mybatipse 플러그인

mybatipse 플러그인은 Mapper의 `메소드명`과 mybatis의 `<sql>`을 `ctrl + L-click`으로 연결해주는 편의성을 제공합니다.


#### (erwin) database connection

우선 display 를 `물리 모델`로 변경합니다.

상단 메뉴 `Database` > `Database Connection` 선택하면 아래 팝업 창이 열립니다.

`Connection String:` 의 값은 tnsnames.ora 에 등록된 항목으로 입력합니다.

#### (regex) not matched word

```
# string
say
hello
world

# regex
\b(?!hello)\b\w+

# string
release-service-bom
release-service-www
snapshot-service-bom
snapshot-service-www

# regex
^release\-(?!.*\-bom).*
```

#### (maven) release github

```
<scm>
  <connection>scm:git:git@github.com:lislroow/pilot.git</connection>
</scm>
<plugin>
  <groupId>org.apache.maven.plugins</groupId>
  <artifactId>maven-release-plugin</artifactId>
  <version>3.0.0-M1</version>
  <configuration>
    <autoVersionSubmodules>true</autoVersionSubmodules>
    <goals>deploy</goals>
    <scmCommentPrefix>[jenkins]</scmCommentPrefix>
  </configuration>
</plugin>
```

#### (git) tag 

```
# 태그 삭제
$ git tag -d framework-bom-0.2
'framework-bom-0.2' 태그 삭제함 (과거 2c5b9f1)
$ git push origin :framework-bom-0.2
To github.com:lislroow/pilot.git
 - [deleted]         framework-bom-0.2
$

# 태그 조회
$ git tag -l framework-*
framework-bom-0.1

# 태그 추가 (Lightweight 태그)
$ git tag framework-bom-0.2

# 태그 추가 (Annotated 태그)
$ git tag -a framework-bom-0.2 -m "Release framework-bom-0.2"

# 태그 보기
$ git show framework-bom-0.2

# 태그 원격저장소 push (모두 올리기)
$ git push origin --tags
```

#### (git) 특정 경로만 checkout 하기

```
$ git init
$ git config core.sparseCheckout true
#git config --local credential.helper ""
$ git remote add -f origin git@github.com:lislroow/pilot.git
$ echo "bom/framework-bom/*" > .git/info/sparse-checkout
$ git pull origin main
```

#### (maven) version ranges

artifact 의 scope 가 `import` 일 경우에는 `[0.1,)` 형태로 ranges 를 적용할 수 없습니다.

```
<dependencyManagement>
  <dependencies>
    <!-- mgkim.proto -->
    <dependency>
      <groupId>mgkim.proto</groupId>
      <artifactId>proto</artifactId>
      <version>[0.1,)</version>  <!-- 오류 -->
      <version>0.1</version>     <!-- 정상 -->
      <type>pom</type>
      <scope>import</scope>
    </dependency>
    <!-- //mgkim.proto -->
  </dependencies>
</dependencyManagement>
```

#### (github) ssh key 등록

`ssh-keygen -t ed25519 -C "hi@mgkim.net"`

생성된 공개키 파일, `C:\Users\Administrator\.ssh\id_ed25519.pub` 의 내용을 github 에 등록합니다.

github 메뉴 경로: `Settings` > `SSH and GPG keys`


`remote origin` 변경 

`ssh-agent` 는 공개키 인증을 위한 개인키를 보관하는 프로그램으로 여러 서버에 인증이 필요할 경우 사용할 수 있습니다.

등록된 공개키 정상여부 확인을 하기 위해, 키 생성을 한 곳에서 `ssh -T git@github.com` 명령을 실행을 해봅니다.

키 파일의 경로를 명시적으로 지정

`ssh -v -i /C/Users/Administrator/.ssh/id_ed25519.pub -T git@github.com`

`ssh -i C:\Users\Administrator\.ssh\id_ed25519.pub -T git@github.com`


```
Administrator@I5-1135G7 MINGW64 /
$ ssh -T git@github.com
The authenticity of host 'github.com (15.164.81.167)' can't be established.
ED25519 key fingerprint is SHA256:+DiY3wvvV6TuJJhbpZisF/zLDA0zPMSvHdkr4UvCOqU.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added 'github.com' (ED25519) to the list of known hosts.
Hi lislroow! You've successfully authenticated, but GitHub does not provide shell access.
```

github 에 key를 등록한 다음 cli 환경에서 사용하려면 아래 명령을 실행합니다.

```
$ eval "$(ssh-agent -s)"
Agent pid 126681
$ ps -ef | grep ssh-agent
root       31343       1  0 12월14 ?      00:00:00 ssh-agent -s
jenkins   126681       1  0 17:12 ?        00:00:00 ssh-agent -s
jenkins   126683  126640  0 17:12 pts/1    00:00:00 grep --color=auto ssh-agent
$ ssh-add ~/.ssh/id_ed25519
Identity added: /home/jenkins/.ssh/id_ed25519 (jenkins@mgkim.net)
$ 
```

#### (github) unable to read askpass 오류

오류 상황입니다.

```
$ git push origin

(gnome-ssh-askpass:19816): Gtk-WARNING **: 10:22:08.209: cannot open display: 
error: unable to read askpass response from '/usr/libexec/openssh/gnome-ssh-askpass'
Username for 'https://github.com': 
```

`SSH_ASKPASS` 변수를 unset 하면 됩니다.

```
$ echo $SSH_ASKPASS
/usr/libexec/openssh/gnome-ssh-askpass
$ unset SSH_ASKPASS
```

#### (github) Personal access tokens

`Settings` > `Developer settings` > `Personal access tokens` 이동 후

`Generate new token` 버튼 클릭으로 token 생성 (`repo` 만 체크하면 push 할 수 있음)

token 생성 후 이클립스에서 id에 email 입력, password 에 생성된 토큰 입력

```
# token-name: centos
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
```

#### (maven) release

명령어

```
$ mvn -B clean release:prepare release:perform deploy
```

$M2_HOME/conf/settings.xml 파일

```
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
  http://maven.apache.org/xsd/settings-1.0.0.xsd">
  <servers>
    <server>
      <id>nexus-release</id>
      <username>admin</username>
      <password>passwd</password>
    </server>
    <server>
      <id>nexus-snapshot</id>
      <username>admin</username>
      <password>passwd</password>
    </server>
  </servers>
  <mirrors>
    <mirror>
      <id>nexus</id>
      <name>nexus</name>
      <url>http://nexus/repository/maven-group/</url>
      <mirrorOf>*</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

pom.xml 파일

```
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-release-plugin</artifactId>
      <version>3.0.0-M1</version>
      <!-- 필수 사항 -->
      <configuration>
        <autoVersionSubmodules>true</autoVersionSubmodules>
        <goals>deploy</goals>
        <username>mgkim</username>
        <password>passwd</password>
      </configuration>
      <!-- //필수 사항 -->
    </plugin>
  </plugins>
</build>

<!-- 필수 사항 -->
<scm>
  <connection>scm:svn:svn://develop/test/trunk/proto.www</connection>
</scm>
<!-- //필수 사항 -->

<distributionManagement>
  <snapshotRepository>
    <id>mgkim-snapshot</id>
    <url>http://nexus/repository/maven-mgkim-snapshot/</url>
  </snapshotRepository>
  <repository>
    <id>mgkim-release</id>
    <url>http://nexus/repository/maven-mgkim-release/</url>
  </repository>
</distributionManagement>
```

#### (maven) dependency

명령어: dependency:resolve

javadoc 다운로드

```
$ mvn dependency:resolve -Dclassifier=javadoc
```

명령어: dependency:sources

sources 다운로드

```
$ mvn dependency:sources
```

#### (maven) deploy:deploy-file

명령어

```
set JAVA_HOME=Z:\develop\java\openjdk-11.0.2
set M2_HOME=Z:\develop\build\maven-3.6.3
set PATH=%JAVA_HOME%\bin;%M2_HOME%\bin;%PATH%
set NEXUS_REPO=-DrepositoryId=nexus-release -Durl=http://nexus/repository/maven-public-hosted/
set GROUP_ID=net.mgkim
set ARTIFACT_ID=spring-core
set VERSION=1.0.0
set FILE=Z:\mgkim-spring-core-1.0.0.jar

%M2_HOME%\bin\mvn.cmd -U deploy:deploy-file -DgroupId=%GROUP_ID% -DartifactId=%ARTIFACT_ID% -Dversion=%VERSION% -Dpackaging=jar -Dfile=%FILE% %NEXUS_REPO%
```

플러그인

```
<build>
  <plugins>
    <plugin>
      <groupId>org.apache.maven.plugins</groupId>
      <artifactId>maven-deploy-plugin</artifactId>
      <version>3.0.0-M1</version>
    </plugin>
  </plugins>
</build>
```
**2021.12.14 nexus deploy 401 unauthorized**

mvn deploy 에 전달된 인자 `-DrepositoryId=nexus-release` 이 참조하는 settings.xml 의 `<Servers>` 의 id/passwd 정보가 있어야 합니다.

```
  <servers>
    <server>
      <id>nexus-release</id>
      <username>admin</username>
      <password>***(passwd)***</password>
    </server>
  </servers>
```

#### (win) port-forwarding cmd

```
# 설정
> netsh interface portproxy add v4tov4 listenport=8222 listenaddress=0.0.0.0 connectport=22 connectaddress=172.28.200.20

# 해제
> netsh interface portproxy delete v4tov4 listenport=8222 listenaddress=0.0.0.0

# 확인
> netsh interface portproxy show v4tov4
```

#### (win) 파일 공유 설정

windows 에서 파일 공유 시 권한이 없다는 메시지가 나오는 경우가 있음

windows 계정에 패스워드가 설정되어 있지 않으면 발생하는 사항

```
# 비밀번호 설정하기
> net user administrator *
```

centos 에서 windows 공유 디렉토리 mount

```
$ mkdir /share
$ mount -t cifs //172.28.200.1/share /share -o username=administrator,password=1
$ df -h
Filesystem            Size  Used Avail Use% Mounted on
devtmpfs              3.8G     0  3.8G   0% /dev
tmpfs                 3.9G   12K  3.9G   1% /dev/shm
tmpfs                 3.9G   14M  3.8G   1% /run
tmpfs                 3.9G     0  3.9G   0% /sys/fs/cgroup
/dev/nvme0n1p9         76G   15G   61G  20% /
/dev/nvme0n1p8        3.0G  2.7G  378M  88% /var
/dev/nvme0n1p7        5.0G  2.6G  2.4G  53% /home
/dev/nvme0n1p2        100G   27G   74G  27% /data
/dev/nvme0n1p5         20G  5.0G   16G  25% /app
/dev/nvme0n1p3         30G  9.8G   21G  33% /prod
/dev/nvme0n1p1        474M  149M  326M  32% /boot
tmpfs                 781M     0  781M   0% /run/user/0
//172.28.200.1/share  345G  284G   62G  83% /share
$ vi /etc/fstab
//172.28.200.1/share /share cifs username=administrator,password=1 0 0
```

#### (vmware) nat 설정

`vmware` > `Edit` > `Virtual Network Editor`

`NAT Settings...` > `Gateway IP` 확인

Subnet IP: 172.28.200.0, Subnet mask: 255.255.255.0

vmware 의 guest os는 172.28.200.2~254 로 설정하고, host os(windows) 와 통신은 172.28.200.1 로 합니다. 

#### (7z) 7z 압축 cmd

```
> "C:\Program Files\7-Zip\7z.exe" a -mx7 -mmt Z:\project.zip "Z:\project"
> "C:\Program Files\7-Zip\7z.exe" a -mx5 -t7z Z:\project.zip "Z:\project" -xr!target -xr!node_modules
```

target 디렉토리와 node_modules 디렉토리는 압축 대상에서 제외됩니다.


#### (win) xcopy cmd

```
> xcopy C:\exp\*.* Z:\exp\ /d/i/s/c/y
```

#### (chrome) https 자동 접속 현상

* `chrome://net-internals/#hsts` 로 이동
* `Delete domain security policies` 에서 해당 도메인 delete
* `chrome://restart` chrome 재시작

#### (git) config cmd

```
> git config --global core.autocrlf true
> git config --global user.email hi@mgkim.net
> git config --global user.name 김명구
```

#### (git) pre-commit shell

git-commit 을 하기 전에 사전 검사를 하기 위한 코드를 bash-shell 로 체크하는 방법입니다.

```
# project/.git/hooks/pre-commit
#!/bin/sh
LIST=$(git diff --cached --name-only --diff-filter=ACRM)

for file in $LIST
do
  if [ $file = ".settings/org.eclipse.wst.common.component" ]; then
    echo "이클립스 설정 파일($file)은 commit을 할 수 없습니다."
    exit 1
  fi
done
exit 0
```

#### (git) git-remote

```
$ git remote -v
origin  https://github.com/lislroow/dlog.git (fetch)
origin  https://github.com/lislroow/dlog.git (push)

$ git remote set-url origin git@github.com:lislroow/dlog.git

$ git remote -v
origin  git@github.com:lislroow/dlog.git (fetch)
origin  git@github.com:lislroow/dlog.git (push)
```

#### (git) git-log

- `git log --branches --not --remotes`: commit 목록 중 원격지에 push 하지 않은 항목 출력
- `git log --oneline --graph`: commit 목록을 1 line 으로 출력하면서 graph 로 표시
- `git log -p -1`: commit 목록 중 최근 1개에 대하여 `-p`(patch) diff 출력
- `git log -p -S 문자열`: patch 에 문자열이 포함된 commit 목록 출력
- `git log --since='2022-02-26 14:00'`: '2022-02-26 14:00' 부터 지금까지의 commit 목록 출력 (since/until)

주요 옵션

| 옵션           |
| -------------- |
| -p             |
| --stat         |
| --shortstat    |
| --name-only    |
| --name-status  |
| --graph        |
| --pretty       |
| --oneline      |

범위 제한 옵션

| 옵션               |
| ------------------ |
| -(n)               |
| --since, --after   |
| --until, --before  |
| --author           |
| --committer        |
| --grep             |
| --S                |

#### (git) git-restore

- `git restore path-to-file`: working-directory 의 파일 변경 취소
- `git restore --staged path-to-file`: Index 의 파일 변경 취소

#### (git) git-reset

- `git reset -- path-to-file`: Index 의 파일(Index에 파일이 있다는 것은 staged 상태임)을 unstaging 으로 변경
- `git checkout path-to-file`

reset 명령은 HEAD가 가리키는 브랜치의 commit 을 바꿉니다.

옵션은 \-\-soft, \-\-mixed, \-\-hard 3가지가 있으며 기본은 \-\-mixed 입니다.

특정 파일 1개를 3회 commit 을 한 상태, 각 commit 의 해시 값은 v1, v2, v3 라고 가정합니다.

reset 명령으로 commit 상태를 v2로 변경할 때, 옵션별 실행 결과입니다.

| 옵션         | <center>결과</center>                      |
| ------------ | ------------------------------------------ |
| \-\-soft  v2 | HEAD: v2, Index: v3, working-directory: v3 |
| \-\-mixed v2 | HEAD: v2, Index: v2, working-directory: v3 |
| \-\-hard  v2 | HEAD: v2, Index: v2, working-directory: v2 |

commit 해시 값을 파라미터로 전달하지 않고, 이전의 commit 해시 값으로 변경할 경우 아래와 같이 실행합니다.

`git reset --soft HEAD~`

같이 commit 해야할 파일을 실수로 누락했을 경우 사용될 수 있습니다.

reset 명령으로 Index 의 특정 파일을 HEAD에서 특정 commit 버전에 포함된 파일로 변경할 수 있습니다.

`git reset v2 -- file.txt`

HEAD 의 v2 버전 상태의 file.txt를 Index에 적용합니다.

최근 2건의 commit 을 하나로 합쳐서 1건의 commit 으로 정리하고자 할 때 아래와 같이 reset 명령을 사용합니다.

`git reset --soft HEAD~2` 혹은 `git reset --soft HEAD@{2}`

reset 명령은 Untracked 파일(로컬에서 신규 생성한 파일)은 그대로 유지합니다.


#### (git) git-push

- `git push origin +test`: 원격지 브랜치 test에 강제 push 를 합니다. `git push origin test -f` 와 같습니다. (강제 push를 하게되면 원격지의 commit history 가 덮어씌워 집니다.)


#### (git) git-clean

Untracked 파일만 삭제하는 명령입니다. (tracked 파일은 대상이 아닙니다.)

- `git clean -f`: 파일만 삭제
- `git clean -f -d`: 파일 및 디렉토리 삭제
- `git clean -f -d -x`: 파일 및 디렉토리 및 무시된 파일 삭제
- `git clean -n`: 삭제될 대상을 확인

#### (git) git-checkout

`git checkout branch`와 `git reset --hard 브랜치` 는 


#### (git) git-commit

- `git commit --amend`: Index 에 추가된 항목으로 commit 을 재작성

```
$ git commit -m '메시지'
$ git add forgotten_file
$ git commit --amend
```

#### (git) git-ls-files

- `git ls-files -s`: (Index)


#### (git) git-branch

- `git branch --list`
- `git branch -vv`
- `git branch -avv`: 로컬/원격지 모든 브랜치 조회하면서 tracking 상태 확인
- `git branch test --track origin/main`: 원격지 origin/main 브랜치를 start-point 로 하는 test 브랜치 생성
- `git branch --set-upstream-to origin/main`: 현재 로컬 브랜치를 원격지 origin/main 브랜치로 tracking 하도록 설정
- `git branch test --set-upstream-to origin/main`: 로컬 브랜치 test를 원격지 origin/main 브랜치로 tracking 하도록 설정
- `git switch test`
- `git push origin test`: 로컬 브랜치 test를 원격지에 생성
- `git push origin :test`: 원격지 브랜치 test를 삭제
- `git branch -d`: merge 하지 않은 커밋을 담고 있는 브랜치는 `git branch -D` 로 강제 삭제할 수 있음
- `git branch -r`: 원격지 브랜치 조회
- `git branch -a`: 로컬/원격지 브랜치 모두 조회
- `git remote show origin`: 로컬/원격지 tracking 상태 확인
- `git remote prune origin`: 원격 브랜치와 유효하지 않는 참조를 삭제
- `git remote update --prune`
- `git fetch -p`: fetch 를 실행하면서 원격 브랜치의 참조가 유효하지 않는 상태의 브랜치를 제거


#### (git) git-config (alias)

- `git config --global alias.br branch`
- `git config --global alias.unstage 'reset HEAD --'`
- `git config --global alias.last 'log -1 HEAD'`


#### (git) git-diff

- `git diff`
- `git diff HEAD`
- `git diff HEAD --color-words`
- `git diff HEAD --word-diff`


#### (apache) selinux

```
chcon -Rt httpd_log_t /outlog/WEB
chcon -Rt httpd_sys_content_t /app/WEB/dlog
setsebool -P httpd_can_network_connect on

systemctl restart httpd
```


#### (oracle12) sysctl 설정

파일: /etc/sysctl.conf

```
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.shmall = 2097152
kernel.shmmax = 4056393728
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048586
```

반영: `sysctl -p`
확인: `sysctl -a`

#### (oracle12) limits 설정

/etc/security/limits.conf

```
oracle soft nproc 2047
oracle hard nproc 16384
oracle soft nofile 1024
oracle hard nofile 65536
```

#### (oracle12) max_string_size = EXTENDED

```
startup mount;
alter database open migrate;
select con_id, name, open_mode from v$pdbs;
alter session set container=PDB$SEED;
alter system set max_string_size=extended scope=spfile;
@?/rdbms/admin/utl32k.sql;
alter session set container=SPADBP;
alter pluggable database SPADBP open upgrade;
alter system set max_string_size=extended scope=spfile;
@?/rdbms/admin/utl32k.sql;
@?/rdbms/admin/utlrp.sql;
alter pluggable database SPADBP close immediate;
```

#### (oracle12) PDB 자동 시작

```
select con_id, name, open_mode from v$pdbs;
CREATE OR REPLACE TRIGGER open_pdbs 
  AFTER STARTUP ON DATABASE 
BEGIN 
  EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE ALL OPEN'; 
END open_pdbs;
/
commit;
```

#### (oracle12) oracle 계정 생성

```
alter session set "_oracle_script"=true;
CREATE TABLESPACE TS_DATA01 DATAFILE '/data/DB/oradata/ora12c/SPADBP/TS_DATA01.dbf' SIZE 1G AUTOEXTEND ON NEXT 10M;
CREATE USER SPADBA IDENTIFIED BY 1 DEFAULT TABLESPACE TS_DATA01;
CREATE USER SPAAPP IDENTIFIED BY SPAAPP1234 DEFAULT TABLESPACE TS_DATA01;
ALTER USER SPADBA QUOTA UNLIMITED ON TS_DATA01;
GRANT CONNECT, RESOURCE, CREATE VIEW, EXP_FULL_DATABASE, IMP_FULL_DATABASE, DBA TO SPADBA;
CREATE ROLE RL_SPA_APP;
GRANT CONNECT, RESOURCE TO RL_SPA_APP;
GRANT RL_SPA_APP TO SPAAPP;
```

#### (oracle12) imp/exp

```
exp.exe SPADBA/1@SPADBP FILE='Z:\SPADBP.dmp' GRANTS=Y INDEXES=Y ROWS=Y CONSTRAINTS=Y TRIGGERS=N COMPRESS=Y DIRECT=N CONSISTENT=N OWNER=(SPADBA)
imp.exe SPADBA/1@SPADBP FILE='Z:\SPADBP.dmp' FEEDBACK=1000 GRANTS=Y INDEXES=Y ROWS=Y CONSTRAINTS=Y IGNORE=N SHOW=N DESTROY=N ANALYZE=Y SKIP_UNUSABLE_INDEXES=N RECALCULATE_STATISTICS=N FROMUSER=SPADBA TOUSER=SPADBA
```

#### (oracle12) drop table 문

```
select 'drop table '||table_name||' cascade constraints;' from user_tables;
```

#### (oracle12) character-set 설정

```
select * from nls_database_parameters where parameter like '%NLS_CHARACTERSET%';
/**
NLS_CHARACTERSET  WE8MSWIN1252
**/
/**
NLS_CHARACTERSET  AL32UTF8
*/

SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER SYSTEM ENABLE RESTRICTED SESSION;
ALTER SYSTEM SET JOB_QUEUE_PROCESSES=0;
ALTER SYSTEM SET AQ_TM_PROCESSES=0;
ALTER DATABASE OPEN;
ALTER DATABASE CHARACTER SET INTERNAL_USE AL32UTF8;
SHUTDOWN IMMEDIATE;
STARTUP;
```
