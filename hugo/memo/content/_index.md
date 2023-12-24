
### * `xmllint`
```xml
# https://repo1.maven.org/maven2/javax/servlet/servlet-api/maven-metadata.xml
XML_TEXT=$(cat <<- EOF
<?xml version="1.0" encoding="UTF-8"?>
<metadata modelVersion="1.1.0">
  <groupId>javax.servlet</groupId>
  <artifactId>servlet-api</artifactId>
  <versioning>
    <latest>3.0-alpha-1</latest>
    <release>3.0-alpha-1</release>
    <versions>
      <version>2.2</version>
      <version>2.3</version>
      <version>2.4</version>
      <version>2.4.public_draft</version>
      <version>2.4-20040521</version>
      <version>2.5</version>
      <version>3.0-alpha-1</version>
    </versions>
    <lastUpdated>20111024063317</lastUpdated>
  </versioning>
</metadata>
EOF
)
```

#### - text()
```shell
$ echo ${XML_TEXT} | xmllint --xpath "/metadata/groupId" -
---
<groupId>javax.servlet</groupId>

$ echo ${XML_TEXT} | xmllint --xpath "/metadata/groupId/text()" -
---
javax.servlet
```

#### - count()
```shell
$ echo ${XML_TEXT} | xmllint --xpath "count(//versions/version)" -
---
7
```

#### - last()
```shell
$ echo ${XML_TEXT} | xmllint --xpath "//versions/version[last()]" -
---
<version>3.0-alpha-1</version>

$ echo ${XML_TEXT} | xmllint --xpath "//versions/version[last()]/text()" -
---
3.0-alpha-1
```

#### - for-loop
```shell
cnt=$(echo ${XML_TEXT} | xmllint --xpath "count(//versions/version)" -)
for ((i=1; i<=${cnt}; i++)); do
  echo ${XML_TEXT} | xmllint --xpath "//versions/version[$i]/text()" -
  printf $'\n'
done
---
2.2
2.3
2.4
2.4.public_draft
2.4-20040521
2.5
3.0-alpha-1
```

### * `yum`

#### - yum provides
```shell
$ yum provides xmllint
---
Last metadata expiration check: 2:56:27 ago on Sun Dec 24 11:57:55 2023.
libxml2-2.9.7-16.el8_8.1.i686 : Library providing XML and HTML support
Repo        : baseos
Matched from:
Filename    : /usr/bin/xmllint

libxml2-2.9.7-16.el8_8.1.x86_64 : Library providing XML and HTML support
Repo        : @System
Matched from:
Filename    : /usr/bin/xmllint

libxml2-2.9.7-16.el8_8.1.x86_64 : Library providing XML and HTML support
Repo        : baseos
Matched from:
Filename    : /usr/bin/xmllint
```

#### - yum history 
```shell
$ yum history
---
ID     | Command line                                             | Date and time    | Action(s)      | Altered
---------------------------------------------------------------------------------------------------------------
    12 | install expat-devel                                      | 2023-12-24 00:23 | Install        |    1   
    11 | install lrzsz                                            | 2023-12-24 00:11 | Install        |    1   
    10 | install xmlstarlet                                       | 2023-12-16 20:47 | Install        |    1   
     9 | erase httpd                                              | 2023-12-15 21:14 | Removed        |   17 EE
     8 | install httpd-devel                                      | 2023-12-05 23:59 | Install        |    8   
     7 | install -y httpd                                         | 2023-12-03 20:17 | Install        |    9   
     6 | install -y java-1.8.0-openjdk-devel.x86_64               | 2023-12-03 19:35 | Install        |    6   
     5 | update                                                   | 2023-12-02 09:20 | I, U           |  261 EE
     4 | install nmap-ncat                                        | 2023-12-02 09:19 | Upgrade        |    1   
     3 | install yum-utils                                        | 2023-10-03 12:50 | Install        |    1   
     2 | update -y                                                | 2023-10-03 12:42 | I, U           |  128   
     1 |                                                          | 2023-10-03 12:14 | Install        |  778 EE
```

### * `rpm`

#### - rpm -qa
```shell
$ rpm -qa -last
---
java-1.8.0-openjdk-devel-1.8.0.392.b08-4.el8_8.x86_64 Sun Dec  3 19:35:32 2023

$ rpm -qa --qf '%{INSTALLTIME:date} %{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n'
---
Sun Dec  3 19:35:32 2023 java-1.8.0-openjdk-devel-1.8.0.392.b08-4.el8_8.x86_64
```

#### - rpm -ql
```shell
$ rpm -ql java-1.8.0-openjdk-devel-1.8.0.392.b08-4.el8_8.x86_64
```

### * `tar`

#### - zst 해제: tar -I zstd
```shell
$ wget https://repo.msys2.org/msys/x86_64/zsh-5.8-5-x86_64.pkg.tar.zst
$ tar -I zstd -xvf zsh-5.8-5-x86_64.pkg.tar.zst
```

#### - 분할 압축: split -b 3072m
```shell
# compress
$ tar cvfz - target | split -b 3072m - target.tgz

# decompress
$ cat target.tgz.* | tar zxvf -
```

#### - 디렉토리 제외: --exclude
```shell
$ tar cvfz tomcat.tgz --exclude 'work' --exclude 'logs' /engn/servers
```


### * `lsof`
```shell
$ lsof -u jenkins -a +D /data
$ lsof -i 4
$ lsof -t -i TCP:8100
$ ps -ef | grep `lsof -t -i tcp:8100`
$ lsof -t -i tcp:8100 | xargs kill -9 
```


### * `xargs`

```shell
# 공백 문자 포함 파일명
$ find . -type f -name '*.jsp' | xargs -I{} ls -al {}
```

### * `hostname`
```shell
$ hostnamectl set-hostname develop
```

### * `systemctl`

#### - 종속성 확인

```shell
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

### * `bash`

#### - BASE_DIR
```shell
#!/bin/bash

# BASE_DIR: script 파일의 디렉토리 경로
BASE_DIR=$( cd $( dirname $0 ) && pwd -P )
```

#### - 파일명, 확장자
```shell
$ FILE_NAME="a.txt"

$ echo ${FILE_NAME%.*}
--
a

$ echo ${FILE_NAME##*.}
--
txt
```

#### - case 문
```shell
case $var in
  a*)
    ;;
  a?)
    ;;
  a[bc])
    ;;
esac
```

### * `vim`

#### - $HOME/.vimrc
.vimrc 에는 # 주석 불가

```
set paste

set ts=2
set sts=2
set shiftwidth=2
```

### * `self-signed-cert`

#### - "git-bash" ca-bundle.crt
git-bash 에서 ssl 통신 대상 서버가 ca 에 등록되지 않은 crt 인증서를 사용할 경우 curl 을 사용할 때 오류 발생

crt 인증서를 `C:\Program Files\Git\mingw64\ssl\certs\ca-bundle.crt` 에 추가

#### - "java" cacerts
java 에서 ssl 통신 대상 서버가 ca 에 등록되지 않은 crt 인증서를 사용할 경우 `$JAVA_HOME/bin/keytool` 명령으로 java 에 crt 인증서 등록

```shell
# 인증서 등록
$ keytool -importcert \
    -keystore $JAVA_HOME/lib/security/cacerts \
    -file "hello.crt" -alias "hello"
---
키 저장소 비밀번호 입력: (changeit 입력)
이 인증서를 신뢰합니까? [아니오]:  (y 입력)
인증서가 키 저장소에 추가되었습니다.

# 인증서 조회
$ keytool -list \
    -keystore $CACERTS
---
키 저장소 비밀번호 입력: (changeit 입력)
hello, 2020. 5. 8, trustedCertEntry,

# 인증서 삭제
$ keytool -delete \
    -keystore $CACERTS \
    -alias "hello"
```

#### - "centos" update-ca-trust extract
```shell
$ cp hello.crt /etc/pki/ca-trust/source/anchors/
$ update-ca-trust extract

# update-ca-trust 명령으로 등록이 안될 경우,
# /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem 파일에 crt 직접 추가
$ chmod u+w /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
$ cat hello.crt >> /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
$ chmod u-w /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
```

#### - "windows" certutil
```shell
certutil -addstore -f "ROOT" hello.crt
```


### * `ls`

#### - ls --time-style
```shell
# 시각까지 표시
alias ls='ls --time-style long-iso '
$ ls -al a.txt
---
-rw-r--r-- 1 root root 0 1981-07-19 00:00 a.txt
```

### * `find`

#### - find -newer -samefile
```shell
# 기준이 되는 파일을 생성 (e.g 1981년 07월 19일)
$ touch -t 198107190000.00 a.txt
$ ls -al a.txt
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

### * `curl`

#### - curl -w '%{http_code}'
- `-w`, --write-out <format> Use output FORMAT after completion
- `-s`, --silent        Silent mode
- `-o`, --output <file> Write to file instead of stdout

```shell
$ curl http://localhost:8010/ \
  -w '%{http_code}' \
  -o /dev/null \
  -s
---
200
```

### * `xmlstarlet` 

#### - 설치
```shell
$ dnf install epel-release
$ yum install xmlstarlet
```

### * `firewalld`
/etc/firewalld/zones/public.xml

### * `selinux`
/etc/selinux/config

`SELINUX=disabled`

변경 사항 적용 시 `shutdown -r now` 필요

### * `network-scripts`
/etc/sysconfig/network-scripts/ifcfg-ens33 
```properties
BOOTPROTO="none"
IPV6INIT="no"
IPADDR="172.28.200.30"
PREFIX="24"
GATEWAY="172.28.200.2"
DNS1="8.8.8.8"
```

변경 사항 적용
```shell
$ nmcli networking off
$ nmcli networking on
$ systemctl restart NetworkManager
```

### * `openssl`

#### - pem 키 생성
```shell
# 암호화하지 않은 개인키
$ openssl genrsa -out private_key.pem 2048

# 3des로 암호화된 개인키 생성
# passphrase를 입력이 필요합니다.
$ openssl genrsa -des3 -out enc_private_key.pem 2048
```

#### - pem 키 패스워드 추가/제거
```shell
# 기존 개인키에 패스워드 추가
$ openssl rsa -des3 -in private_key.pem -out enc_private_key.pem

# 기존 개인키에 패스워드 제거
$ openssl rsa -in enc_private_key.pem -out private_key.pem
```


### * `windows`

#### - setx
```
setx /m JAVA_HOME "D:\develop\java\openjdk-11.0.2"
```

#### - xcopy
``` 
xcopy C:\temp\*.* D:\temp /d/i/s/c/y
```

#### - netsh
```shell
# 설정
$ netsh interface portproxy add v4tov4 listenport=8222 listenaddress=0.0.0.0 connectport=22 connectaddress=172.28.200.20

# 해제
$ netsh interface portproxy delete v4tov4 listenport=8222 listenaddress=0.0.0.0

# 확인
$ netsh interface portproxy show v4tov4
```


#### - 파일공유

- 비밀번호 설정하기
  ```
  $ net user administrator *
  ```
- centos 에서 windows 공유 디렉토리 mount
  ```shell
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

#### - "vmware" nat 설정
- `vmware` > `Edit` > `Virtual Network Editor`
- `NAT Settings...` > `Gateway IP` 확인
- Subnet IP: 172.28.200.0, Subnet mask: 255.255.255.0
- vmware 의 guest os는 172.28.200.2~254 로 설정하고, host os(windows) 와 통신은 172.28.200.1 로 합니다. 

#### - "7z"
```
$ 7z a -mx7 -mmt /d/project.zip /d/develop
$ 7z a -mx5 -t7z /d/project.zip /d/develop -xr!target -xr!node_modules
```

#### - "chrome" hsts
- `chrome://net-internals/#hsts` 이동
- `Delete domain security policies` 에서 해당 도메인 delete
- `chrome://restart` chrome 재시작


### * `maven`

#### - master-password 생성
`-emp`,--encrypt-master-password <arg>   Encrypt master security password 

- `mvn -emp 패스워드`명령으로 암호화 패스워드 생성 
- `~/.m2/settings-security.xml` 파일에 저장

```shell
# "-emp" 는 "--encrypt-master-password" 입니다.
$ mvn -emp 패스워드
---
{h/JmfOxXj2IH/whyc5/7wpvOT5AeBmlHV/nzmk7rzY+i7vEvpg46lHddfEwHFtN1}

$ cat << EOF > ~/.m2/settings-security.xml
<settingsSecurity>
  <master>{h/JmfOxXj2IH/whyc5/7wpvOT5AeBmlHV/nzmk7rzY+i7vEvpg46lHddfEwHFtN1}</master>
</settingsSecurity>
EOF
```

#### - password 암호화
`-ep`,--encrypt-password <arg>           Encrypt server password

- `mvn -ep 패스워드`명령으로 nexus 암호화 패스워드 생성
 `$M2_HOME/conf/settings.xml`의 `<password>`에 추가합니다.
```shell
$ mvn -ep '패스워드'
---
{nvTOxUicu5EHTqNwVFkrSKjAQnANDMwZy6sCuPND00w=}

$ vi $M2_HOME/conf/settings.xml
---
<server>
  <id>nexus-snapshot</id>
  <username>admin</username>
  <password>{nvTOxUicu5EHTqNwVFkrSKjAQnANDMwZy6sCuPND00w=}</password>
</server>
```

#### - "plugin" deploy, release

- `spring-boot:repackage` 플러그인: spring-boot 를 배포할 때 의존성 라이브러리를 포함하여 executable-jar 생성
- `maven-deploy-plugin` 를 `nexus-staging-maven-plugin` 로 교체
- `maven-release-plugin` 플러그인: release 버전의 아티팩트를 nexus 에 배포 후 버전을 올려주는 기능

```xml
<scm>
  <connection>scm:git:git@github.com:lislroow/pilot.git</connection>
</scm>
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

#### - "goal" help:evaluate
```
$ mvn help:evaluate -Dexpression=settings.localRepository -q -DforceStdout
```

#### - "goal" deploy:deploy-file
version 에 `-SNAPSHOT` 이 포함되어 있으면 release 저장소에 deploy 불가

```shell
MVN_ARGS=""
MVN_ARGS="${MVN_ARGS} -DpomFile=${PROJECT_BASE}/pom.xml"
MVN_ARGS="${MVN_ARGS} -Dfile=${PROJECT_BASE}/target/${JAR_FILE}"

if [[ "${JAR_FILE}" = *"-SNAPSHOT"* ]]; then
  MVN_ARGS="${MVN_ARGS} -DrepositoryId=maven-snapshot"
  MVN_ARGS="${MVN_ARGS} -Durl=http://nexus/repository/maven-snapshot/"
else
  MVN_ARGS="${MVN_ARGS} -DrepositoryId=maven-release"
  MVN_ARGS="${MVN_ARGS} -Durl=http://nexus/repository/maven-release/"
fi

mvn deploy:deploy-file $MVN_ARGS
```

#### - "goal" release
```shell
$ mvn -B clean release:prepare release:perform deploy
```

- $M2_HOME/conf/settings.xml
  ```xml
  <?xml version="1.0" encoding="UTF-8"?>
  <settings xmlns="...">
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
- pom.xml
  ```xml
  <scm>
    <connection>scm:svn:svn://develop/test/trunk/proto.www</connection>
  </scm>
  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-release-plugin</artifactId>
        <version>3.0.0-M1</version>
        <configuration>
          <autoVersionSubmodules>true</autoVersionSubmodules>
          <goals>deploy</goals>
          <username>mgkim</username>
          <password>passwd</password>
        </configuration>
      </plugin>
    </plugins>
  </build>
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

#### - "goal" dependency
```shell
$ mvn dependency:resolve -Dclassifier=javadoc
$ mvn dependency:sources
$ mvn dependency:get -Dartifact=javax.servlet:javax.servlet-api:4.0.1:jar
```

#### - "goal" deploy:deploy-file
```shell
mvn -U deploy:deploy-file \
  -DrepositoryId=nexus-release \
  -Durl=http://nexus/repository/maven-public-hosted/ \
  -DgroupId=net.mgkim \
  -DartifactId=spring-core \
  -Dversion=1.0.0 \
  -Dpackaging=jar \
  -Dfile=spring-core-1.0.0.jar
```
- settings.xml 파일 `nexus-release` 항목에 username/password 가 일치하지 않을 경우, 401 발생
```xml
  <servers>
    <server>
      <id>nexus-release</id>
      <username>admin</username>
      <password>***(passwd)***</password>
    </server>
  </servers>
```

### * `nexus`
#### - hosted 저장소 curl PUT
```shell
$ REPO="http://nexus/repository/maven-public-hosted"
$ curl -u {id}:{passwd} \
    -X PUT \
    -T org/apache/poi/poi/3.10-FINAL/poi-3.10-FINAL.jar \
    ${REPO}/org/apache/poi/poi/3.10-FINAL/poi-3.10-FINAL.jar
```

### * `regex`
#### - not matched word
```regex
say
hello
world
---
\b(?!hello)\b\w+
```


### * `git`

#### - 일반 옵션
```shell
$ git config --global core.autocrlf true
$ git config --global user.name 김명구
$ git config --global user.email myeonggu.kim@kakao.com
$ git config --global core.safecrlf false
$ git config --global pull.ff only
$ git config --global alias.br branch
$ git config --global alias.unstage 'reset HEAD --'
$ git config --global alias.last 'log -1 HEAD'
```

#### - commit
```
$ git commit -m '메시지'
$ git add forgotten_file
$ git commit --amend
```

#### - pre-commit
git-commit 을 하기 전에 사전 검사를 하기 위한 코드를 bash-shell 로 체크하는 방법입니다.
```shell
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

#### - push
- `git push origin +test`: 원격지 브랜치 test에 강제 push 를 합니다.
- `git push origin test -f` 와 같습니다. 
- 강제 push를 하게되면 원격지의 commit history 가 덮어씌워 집니다.

#### - remote
```
$ git remote -v
---
origin  https://github.com/lislroow/dlog.git (fetch)
origin  https://github.com/lislroow/dlog.git (push)

$ git remote set-url origin git@github.com:lislroow/dlog.git

$ git remote -v
---
origin  git@github.com:lislroow/dlog.git (fetch)
origin  git@github.com:lislroow/dlog.git (push)
```

#### - log
- `git log --branches --not --remotes`: commit 목록 중 원격지에 push 하지 않은 항목 출력
- `git log --oneline --graph`: commit 목록을 1 line 으로 출력하면서 graph 로 표시
- `git log -p -1`: commit 목록 중 최근 1개에 대하여 `-p`(patch) diff 출력
- `git log -p -S 문자열`: patch 에 문자열이 포함된 commit 목록 출력
- `git log --since='2022-02-26 14:00'`: '2022-02-26 14:00' 부터 지금까지의 commit 목록 출력 (since/until)

#### - restore
- `git restore path-to-file`: working-directory 의 파일 변경 취소
- `git restore --staged path-to-file`: Index 의 파일 변경 취소

#### - reset
- `git reset -- path-to-file`: Index 의 파일(Index에 파일이 있다는 것은 staged 상태임)을 unstaging 으로 변경
- `git checkout path-to-file`

#### - clean
- `git clean -f`: 파일만 삭제
- `git clean -f -d`: 파일 및 디렉토리 삭제
- `git clean -f -d -x`: 파일 및 디렉토리 및 무시된 파일 삭제
- `git clean -n`: 삭제될 대상을 확인

#### - ls-files
- `git ls-files -s`: (Index)

#### - branch
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

#### - diff
- `git diff`
- `git diff HEAD`
- `git diff HEAD --color-words`
- `git diff HEAD --word-diff`

#### - tag
```
$ git tag -d framework-bom-0.2
---
'framework-bom-0.2' 태그 삭제함 (과거 2c5b9f1)

$ git push origin :framework-bom-0.2
---
To github.com:lislroow/pilot.git
 - [deleted]         framework-bom-0.2

$ git tag -l framework-*
---
framework-bom-0.1

$ git tag framework-bom-0.2

$ git tag -a framework-bom-0.2 -m "Release framework-bom-0.2"

$ git show framework-bom-0.2

$ git push origin --tags
```

#### - 특정 경로만 checkout 하기
```
$ git init
$ git config core.sparseCheckout true
#git config --local credential.helper ""
$ git remote add -f origin git@github.com:lislroow/pilot.git
$ echo "bom/framework-bom/*" > .git/info/sparse-checkout
$ git pull origin main
```

### * `github`

#### - ssh key 등록

- `ssh-keygen -t ed25519 -C "hi@mgkim.net"`
- `C:\Users\Administrator\.ssh\id_ed25519.pub` github 등록
- github 메뉴: `Settings` > `SSH and GPG keys`
- `ssh -v -i /C/Users/Administrator/.ssh/id_ed25519.pub -T git@github.com`

```shell
# ssh key 테스트
$ ssh -T git@github.com
--- 성공일 경우
Hi lislroow! You've successfully authenticated, but GitHub does not provide shell access.
--- 실패일 경우
git@github.com: Permission denied (publickey).
```

#### - ssh-agent 실행
```shell
$ eval "$(ssh-agent -s)"
---
Agent pid 126681

$ ps -ef | grep ssh-agent
---
root       31343       1  0 12월14 ?      00:00:00 ssh-agent -s
jenkins   126681       1  0 17:12 ?        00:00:00 ssh-agent -s
jenkins   126683  126640  0 17:12 pts/1    00:00:00 grep --color=auto ssh-agent

$ ssh-add ~/.ssh/id_ed25519
---
Identity added: /home/jenkins/.ssh/id_ed25519 (jenkins@mgkim.net)
```

#### - unable to read askpass 오류
`SSH_ASKPASS` 변수 unset 할 것
```
$ git push origin
---
(gnome-ssh-askpass:19816): Gtk-WARNING **: 10:22:08.209: cannot open display: 
error: unable to read askpass response from '/usr/libexec/openssh/gnome-ssh-askpass'
Username for 'https://github.com': 

$ echo $SSH_ASKPASS
---
/usr/libexec/openssh/gnome-ssh-askpass

$ unset SSH_ASKPASS
```

#### - Personal access tokens
- `Settings` > `Developer settings` > `Personal access tokens` 이동 후
- `Generate new token` 버튼 클릭으로 token 생성 (`repo` 만 체크하면 push 할 수 있음)
- token 생성 후 이클립스에서 id에 email 입력, password 에 생성된 토큰 입력
```
# token-name: centos
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
```
