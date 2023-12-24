#### (erwin) database connection

우선 display 를 `물리 모델`로 변경합니다.

상단 메뉴 `Database` > `Database Connection` 선택하면 아래 팝업 창이 열립니다.

`Connection String:` 의 값은 tnsnames.ora 에 등록된 항목으로 입력합니다.


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

#### (centos) zsh

```
$ yum install zsh
$ sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
$ vi ~/.zshrc
ZSH_THEME="agnoster"
$ git clone https://github.com/powerline/fonts.git
$ cd fonts && ./install.sh
$ git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
$ git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
$ vi ~/.zshrc
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)
```

```
$ vi ~/.oh-my-zsh/themes/agnoster.zsh-theme

prompt_newline() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR
%{%k%F{blue}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi

  echo -n "%{%f%}"
  CURRENT_BG=''
}

build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_hg
  prompt_newline
  prompt_end
}
```

#### (git-bash) zsh

zsh-{버전}-x86_64.pkg.tar.zst 링크를 아래 사이트에서 다운로드 합니다.

<a href="https://packages.msys2.org/package/zsh?repo=msys&variant=x86_64" target="_blank">링크</a>

zstandard(`zstd`)가 설치되어 있어야 압축해제가 가능합니다.

git-bash 설치 경로 `C:\Program Files\Git` 에서 압축을 해제합니다. (`usr`, `etc` 디렉토리에 덮어쓰기)

```
$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
$ cat << EOF > ~/.bashrc
exec zsh
EOF
$ vi ~/.oh-my-zsh/themes/agnoster.zsh-theme
prompt_newline() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n "%{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR
%{%k%F{blue}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi

  echo -n "%{%f%}"
  CURRENT_BG=''
}

build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_virtualenv
  prompt_context
  prompt_dir
  prompt_git
  prompt_hg
  prompt_newline
  prompt_end
}
$ vi ~/.zshrc
ZSH_THEME="agnoster"
```

`git-bash` > `Options` > `Looks` > `Theme` 에서 `rosipov` 선택합니다.



#### (cockpit) grafana, grafana-pcp

```
$ yum install grafana grafana-pcp
$ systemctl enable --now grafana-server
```

http://host:3000/ 으로 접속

포트 변경은 `/etc/grafana/grafana.ini` 파일에서 `http_port = 3000` 를 변경하면 됩니다.

서비스 재시작: `systemctl restart grafana-server`


로그인 후 설정

- 좌측 메뉴 `Configuration` > `Plugin` 선택
- `Performance Co-Pilot` 플러그인을 활성화 (enable 버튼 클릭)
- `cockpit-pcp`에서 `redis` 설치 후 `grafana`에서 `Configuration` > `Data Sources` 선택
   <br>(`grafana`는 cockpit-pcp 의 메트릭 정보를 redis 를 통해 가져옵니다. redis 설치는 cockpit 에서 버튼 클릭 한번으로 끝남)
- `HTTP`의 `URL` 항목만 `http://127.0.0.1:44322` 으로 입력 후 `Save & Test` 버튼 클릭


#### (cockpit) cockpit-pcp 설치

시스템모니터링 기능이며 `cockpit-pcp`를 설치하여 메트릭 정보를 볼 수 있습니다.


```
$ yum install cockpit-pcp
$ systemctl enable pmlogger.service
$ systemctl enable pmproxy.service
$ systemctl daemon-reload
$ systemctl start pmlogger.service
$ systemctl start pmproxy.service
```

pmproxy.service 활성화를 통해 여러 머신의 메트릭 정보를 볼 수도 있습니다. (redis 설치됨)



#### (ELK) elasticsearch 패스워드 설정

`elasticsearch`와 `kibana`에 id/pw 방식의 보안을 적용하기 위해 elasticsearch 에 패스워드를 설정합니다.

elasticsearch 에 패스워드를 설정하는 명령어는 `elasticsearch-setup-passwords interactive` 입니다.

오류 내용이 `ERROR: X-Pack Security is disabled by configuration` 으로 나올 경우 설정파일`elasticsearch.yml`이 기본으로 되어있을 경우 발생합니다.

```
$ /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive

Unexpected response code [500] from calling GET http://172.28.200.30:8200/_security/_authenticate?pretty
It doesn't look like the X-Pack security feature is enabled on this Elasticsearch node.
Please check if you have enabled X-Pack security in your elasticsearch.yml configuration file.


ERROR: X-Pack Security is disabled by configuration.
$ 
```

```
102 
103 # 2022.01.27
104 xpack.security.enabled: true
```

설정 추가 후 `systemctl restart elasticsearch` 재시작을하면 `xpack.security.transport.ssl.enabled` 을 추가하라는 메시지가 나옵니다.

```
-- Unit elasticsearch.service has begun starting up.
 1월 27 18:25:13 centos8 systemd-entrypoint[11169]: ERROR: [1] bootstrap checks failed. You must address the points described in the following [1] lines before starting Elasticsearch.
 1월 27 18:25:13 centos8 systemd-entrypoint[11169]: bootstrap check failure [1] of [1]: Transport SSL must be enabled if security is enabled on a [basic] license. Please set [xpack.security.transport.ssl.enabled] to [true] or disa>
 1월 27 18:25:13 centos8 systemd-entrypoint[11169]: ERROR: Elasticsearch did not exit normally - check the logs at /outlog/PROD/es/elasticsearch.log
```

변경 후 재시작을 합니다.

```
103 # 2022.01.27
104 xpack.security.enabled: true
105 xpack.security.transport.ssl.enabled: true
```

`elasticsearch-setup-passwords interactive` 명령으로 패스워드를 설정합니다.

```
$ /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive
Initiating the setup of passwords for reserved users elastic,apm_system,kibana,kibana_system,logstash_system,beats_system,remote_monitoring_user.
You will be prompted to enter passwords as the process progresses.
Please confirm that you would like to continue [y/N]y


Enter password for [elastic]: 
passwords must be at least [6] characters long
Try again.
Enter password for [elastic]: 
Reenter password for [elastic]: 
Enter password for [apm_system]: 
Reenter password for [apm_system]: 
Enter password for [kibana_system]: 
Reenter password for [kibana_system]: 
Enter password for [logstash_system]: 
Reenter password for [logstash_system]: 
Enter password for [beats_system]: 
Reenter password for [beats_system]: 
Enter password for [remote_monitoring_user]: 
Reenter password for [remote_monitoring_user]: 
Changed password for user [apm_system]
Changed password for user [kibana_system]
Changed password for user [kibana]
Changed password for user [logstash_system]
Changed password for user [beats_system]
Changed password for user [remote_monitoring_user]
Changed password for user [elastic]
$
```

elasticsearch 의 security 적용으로 인해 kibana 의 설정을 확인해야합니다.

설정파일`/etc/kibana/kibana.yml`에 아래 내용을 추가하고 kibana를 재시작(`systemctl restart kibana`)합니다.


```
 50 #elasticsearch.username: "kibana_system"
 51 #elasticsearch.password: "pass"
 52 elasticsearch.username: "elastic"
 53 elasticsearch.password: "패스워드"
```


브라우저로 kibana 에 접속하면 id/pw 를 요구합니다.

kibana 설정파일`/etc/kibana/kibana.yml`에 `elasticsearch.password` 값이 평문이 아닌 encryption 문자열로 설정하겠습니다.

- `kibana-keystore` 명령어로 key 저장소 생성
- 생성된 key 저장소에 `elasticsearch.password` 추가

```
# kibana-keystore 의 경로를 확인합니다.
$ rpm -ql kibana | grep '/bin/kibana'
/usr/share/kibana/bin/kibana
/usr/share/kibana/bin/kibana-encryption-keys
/usr/share/kibana/bin/kibana-keystore
/usr/share/kibana/bin/kibana-plugin
$ 
# key 저장소를 생성합니다.
$ /usr/share/kibana/bin/kibana create
A Kibana keystore already exists. Overwrite? [y/N] N
Exiting without modifying keystore.
$
# 이미 key 저장소가 있다고하여 저장소를 확인해보려 했지만 찾을 수 없었습니다.
# 어딘가에 key 저장소가 있다고 생각하고 add 를 합니다.
$ 
$ ./kibana-keystore add elasticsearch.password
Enter value for elasticsearch.password: *********
# 저장된 key 를 확인합니다.
$ ./kibana-keystore list
elasticsearch.password
# kibana.yml 설정파일에 "elasticsearch.password" 항목을 주석처리 합니다.
# kibana 에서 관리하는 key 저장소에 등록된 값으로 사용될 것입니다.
$ vi /etc/kibana/kibana.yml
#elasticsearch.password=패스워드
``` 

kibana-keystore 에 정상적으로 등록되지 않았다면 아래와 같은 로그를 만나게 됩니다.

아래 오류를 보기위해 테스트를 하려면,

```
$ ./kibana-keystore list
elasticsearch.password
$ ./kibana-keystore remove elasticsearch.password
$ ./kibana-keystore list

$ systemctl restart kibana
$ tail -f /outlog/PROD/kibana/kibana.log
```

```
# 서비스 오류 로그: key 를 찾을 수 없을 경우
{"type":"log","@timestamp":"2022-01-27T20:40:02+09:00","tags":["warning","plugins","alerting"],"pid":14494,"message":"APIs are disabled because the Encrypted Saved Objects plugin is missing encryption key. Please set xpack.encryptedSavedObjects.encryptionKey in the kibana.yml or use the bin/kibana-encryption-keys command."}
{"type":"log","@timestamp":"2022-01-27T20:40:02+09:00","tags":["info","plugins","ruleRegistry"],"pid":14494,"message":"Installing common resources shared between all indices"}
{"type":"log","@timestamp":"2022-01-27T20:40:02+09:00","tags":["warning","plugins","reporting","config"],"pid":14494,"message":"Chromium sandbox provides an additional layer of protection, but is not supported for Linux CentOS 8.5.2111\n OS. Automatically setting 'xpack.reporting.capture.browser.chromium.disableSandbox: true'."}
{"type":"log","@timestamp":"2022-01-27T20:40:02+09:00","tags":["warning","process"],"pid":14494,"message":"Error [ProductNotSupportedSecurityError]: The client is unable to verify that the server is Elasticsearch due to security privileges on the server side. Some functionality may not be compatible if the server is running an unsupported product.\n    at /usr/share/kibana/node_modules/@elastic/elasticsearch/lib/Transport.js:576:19\n    at onBody (/usr/share/kibana/node_modules/@elastic/elasticsearch/lib/Transport.js:369:9)\n    at IncomingMessage.onEnd (/usr/share/kibana/node_modules/@elastic/elasticsearch/lib/Transport.js:291:11)\n    at IncomingMessage.emit (node:events:402:35)\n    at endReadableNT (node:internal/streams/readable:1343:12)\n    at processTicksAndRejections (node:internal/process/task_queues:83:21)"}
{"type":"log","@timestamp":"2022-01-27T20:40:03+09:00","tags":["error","elasticsearch-service"],"pid":14494,"message":"Unable to retrieve version information from Elasticsearch nodes. security_exception: [security_exception] Reason: missing authentication credentials for REST request [/_nodes?filter_path=nodes.*.version%2Cnodes.*.http.publish_address%2Cnodes.*.ip]"}

# 서비스 정상 로그
{"type":"log","@timestamp":"2022-01-27T20:51:17+09:00","tags":["warning","plugins","reporting","chromium"],"pid":14712,"message":"Enabling the Chromium sandbox provides an additional layer of protection."}
{"type":"log","@timestamp":"2022-01-27T20:51:19+09:00","tags":["info","plugins","securitySolution","endpoint:metadata-check-transforms-task:0","0","1"],"pid":14712,"message":"no endpoint metadata transforms found"}
{"type":"log","@timestamp":"2022-01-27T20:51:26+09:00","tags":["info","status"],"pid":14712,"message":"Kibana is now available (was degraded)"}
```



#### (centos) 디스크 size 확장

`lsblk` 명령으로 디스크 size 를 확인합니다.

(디스크 sda 가 70G 로 되어있습니다.)

```
$ lsblk 
NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                   8:0    0   70G  0 disk 
├─sda1                8:1    0    1G  0 part /boot
└─sda2                8:2    0   69G  0 part 
  ├─cl_centos8-root 253:0    0 56.7G  0 lvm  /
  ├─cl_centos8-swap 253:1    0    7G  0 lvm  [SWAP]
  └─cl_centos8-home 253:2    0  5.3G  0 lvm  /home
sr0                  11:0    1 1024M  0 rom  
$
```

guest-os 를 shutdown 하고, vmware 에서 디스크 capacity 를 확장합니다.

(디스크 sda 를 80G 확장합니다.)


<br>
guest-os 를 startup 하고 lsblk 로 확장된 크기를 확인합니다.

(디스크 sda 가 80G 로 확장된 것을 확인할 수 있습니다.)

```
$ lsblk
NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                   8:0    0   80G  0 disk 
├─sda1                8:1    0    1G  0 part /boot
└─sda2                8:2    0   69G  0 part 
  ├─cl_centos8-root 253:0    0 56.7G  0 lvm  /
  ├─cl_centos8-swap 253:1    0    7G  0 lvm  [SWAP]
  └─cl_centos8-home 253:2    0  5.3G  0 lvm  /home
sr0                  11:0    1 1024M  0 rom  
$
```

sda2 를 69G 에서 79G 로 확장합니다. 확장에 사용될 명령어는 `growpart` 입니다.

패키지가 설치되어 있지 않으면 yum 으로 설치를 합니다.

```
$ yum install cloud-utils-growpart
$ which growpart
/usr/bin/growpart
```

growpart 명령으로 피지컬 파티션`sda2`의 size를 확장합니다.

확장 전에 피지컬 파티션을 상태를 확인합니다.

```
$ vgdisplay 
  --- Volume group ---
  VG Name               cl_centos8
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               3
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <69.00 GiB
  PE Size               4.00 MiB
  Total PE              17663
  Alloc PE / Size       17663 / <69.00 GiB
  Free  PE / Size       0 / 0   
  VG UUID               tJ9xgp-NhNP-7kPQ-JwKe-y1TQ-8jkP-1U5ox4
   
$
```

growpart 명령으로 size 를 확장합니다.

확장 후 `lsblk`, `vgdisplay` 로 변경된 사항을 확인합니다.

(lsblk 에서 sda2 의 size가 +10G 된 것을 볼 수 있습니다.)

```
$ growpart /dev/sda 2
CHANGED: partition=2 start=2099200 old: size=144701440 end=146800640 new: size=165672927 end=167772127
$ lsblk 
NAME                MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                   8:0    0   80G  0 disk 
├─sda1                8:1    0    1G  0 part /boot
└─sda2                8:2    0   79G  0 part 
  ├─cl_centos8-root 253:0    0 56.7G  0 lvm  /
  ├─cl_centos8-swap 253:1    0    7G  0 lvm  [SWAP]
  └─cl_centos8-home 253:2    0  5.3G  0 lvm  /home
sr0                  11:0    1 1024M  0 rom  
$ 
```

피지컬 파티션`sda2` 에 추가된 용량을 할당해야 합니다. (명령어 `pvresize /dev/sda2`)

할당 후 vgdisplay 에서 `Free PE / Size` 에서 변경된 것을 확인할 수 있습니다.

(`Free  PE / Size       0 / 0   ` > `Free  PE / Size       2560 / 10.00 GiB`)

```
$ vgdisplay 
  --- Volume group ---
  VG Name               cl_centos8
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  4
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               3
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <69.00 GiB
  PE Size               4.00 MiB
  Total PE              17663
  Alloc PE / Size       17663 / <69.00 GiB
  Free  PE / Size       0 / 0   
  VG UUID               tJ9xgp-NhNP-7kPQ-JwKe-y1TQ-8jkP-1U5ox4

$ pvresize /dev/sda2
  Physical volume "/dev/sda2" changed
  1 physical volume(s) resized or updated / 0 physical volume(s) not resized
$ 
$ vgdisplay
  --- Volume group ---
  VG Name               cl_centos8
  System ID             
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  5
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                3
  Open LV               3
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <79.00 GiB
  PE Size               4.00 MiB
  Total PE              20223
  Alloc PE / Size       17663 / <69.00 GiB
  Free  PE / Size       2560 / 10.00 GiB
  VG UUID               tJ9xgp-NhNP-7kPQ-JwKe-y1TQ-8jkP-1U5ox4

$ 
<br>
```

로지컬 파티션`cl_centos8-root`을 확장해야 합니다.

로지컬 파티션을 확인부터 합니다. (명령어 `lvdisplay` 혹은 `df`로 확인할 수 있습니다.)

(확장할 로지컬 파티션은 `/dev/cl_centos8/root` 입니다.)

```
$ df -h
Filesystem                   Size  Used Avail Use% Mounted on
devtmpfs                     3.8G     0  3.8G   0% /dev
tmpfs                        3.8G     0  3.8G   0% /dev/shm
tmpfs                        3.8G  9.5M  3.8G   1% /run
tmpfs                        3.8G     0  3.8G   0% /sys/fs/cgroup
/dev/mapper/cl_centos8-root   57G   43G   15G  75% /
/dev/sda1                   1014M  378M  637M  38% /boot
/dev/mapper/cl_centos8-home  5.4G  372M  5.0G   7% /home
//172.28.200.1/share         345G  234G  112G  68% /share
tmpfs                        775M     0  775M   0% /run/user/0
$ 
$ lvdisplay 
  --- Logical volume ---
  LV Path                /dev/cl_centos8/root
  LV Name                root
  VG Name                cl_centos8
  LV UUID                DzRXf6-roJe-0He9-MBow-ccu0-bWjk-qPxfZS
  LV Write Access        read/write
  LV Creation host, time centos8, 2021-11-28 12:38:35 +0900
  LV Status              available
  # open                 1
  LV Size                <56.66 GiB
  Current LE             14504
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
   
  --- Logical volume ---
  LV Path                /dev/cl_centos8/home
  LV Name                home
  VG Name                cl_centos8
  LV UUID                9dT8j9-MTd1-dlO2-ceHH-vnpS-KtGJ-je2ReA
  LV Write Access        read/write
  LV Creation host, time centos8, 2021-11-28 12:38:35 +0900
  LV Status              available
  # open                 1
  LV Size                <5.34 GiB
  Current LE             1367
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
   
  --- Logical volume ---
  LV Path                /dev/cl_centos8/swap
  LV Name                swap
  VG Name                cl_centos8
  LV UUID                VSq1ve-Dn73-RLjq-q2GP-wa0r-De07-CO7edF
  LV Write Access        read/write
  LV Creation host, time centos8, 2021-11-28 12:38:36 +0900
  LV Status              available
  # open                 2
  LV Size                7.00 GiB
  Current LE             1792
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1
   
$
```

로지컬 파티션의 size 확장 명령어 `lvextend` 를 사용하여 확장합니다.

로지컬 파티션명은 lvdisplay 에 표시되는 `/dev/cl_centos8/root`를 사용해도되고, df 에 표시되는 `/dev/mapper/cl_centos8-root`를 사용해도 됩니다.

(df 에서 `/dev/mapper/cl_centos8-root` 의 size 가 +10G 된 것을 확인할 수 있고, lvdisplay에서도 `LV Size                <56.66 GiB` > `LV Size                <66.66 GiB` 로 변경된 것을 확인할 수 있습니다.)

```
$ lvextend -r -l +100%FREE /dev/cl_centos8/root
  Size of logical volume cl_centos8/root changed from <56.66 GiB (14504 extents) to <66.66 GiB (17064 extents).
  Logical volume cl_centos8/root successfully resized.
meta-data=/dev/mapper/cl_centos8-root isize=512    agcount=4, agsize=3713024 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=1, sparse=1, rmapbt=0
         =                       reflink=1
data     =                       bsize=4096   blocks=14852096, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0, ftype=1
log      =internal log           bsize=4096   blocks=7252, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
data blocks changed from 14852096 to 17473536
$ 
$ df -h
Filesystem                   Size  Used Avail Use% Mounted on
devtmpfs                     3.8G     0  3.8G   0% /dev
tmpfs                        3.8G     0  3.8G   0% /dev/shm
tmpfs                        3.8G  9.5M  3.8G   1% /run
tmpfs                        3.8G     0  3.8G   0% /sys/fs/cgroup
/dev/mapper/cl_centos8-root   67G   43G   25G  64% /
/dev/sda1                   1014M  378M  637M  38% /boot
/dev/mapper/cl_centos8-home  5.4G  372M  5.0G   7% /home
//172.28.200.1/share         345G  234G  112G  68% /share
tmpfs                        775M     0  775M   0% /run/user/0
$ 
$ lvdisplay 
  --- Logical volume ---
  LV Path                /dev/cl_centos8/root
  LV Name                root
  VG Name                cl_centos8
  LV UUID                DzRXf6-roJe-0He9-MBow-ccu0-bWjk-qPxfZS
  LV Write Access        read/write
  LV Creation host, time centos8, 2021-11-28 12:38:35 +0900
  LV Status              available
  # open                 1
  LV Size                <66.66 GiB
  Current LE             17064
  Segments               2
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:0
   
  --- Logical volume ---
  LV Path                /dev/cl_centos8/home
  LV Name                home
  VG Name                cl_centos8
  LV UUID                9dT8j9-MTd1-dlO2-ceHH-vnpS-KtGJ-je2ReA
  LV Write Access        read/write
  LV Creation host, time centos8, 2021-11-28 12:38:35 +0900
  LV Status              available
  # open                 1
  LV Size                <5.34 GiB
  Current LE             1367
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:2
   
  --- Logical volume ---
  LV Path                /dev/cl_centos8/swap
  LV Name                swap
  VG Name                cl_centos8
  LV UUID                VSq1ve-Dn73-RLjq-q2GP-wa0r-De07-CO7edF
  LV Write Access        read/write
  LV Creation host, time centos8, 2021-11-28 12:38:36 +0900
  LV Status              available
  # open                 2
  LV Size                7.00 GiB
  Current LE             1792
  Segments               1
  Allocation             inherit
  Read ahead sectors     auto
  - currently set to     8192
  Block device           253:1
   
$
```


#### (jenkins) AnsiColor 플러그인

플러그인 설치 후 개별 job 의 `구성`에서 `빌드 환경`에 `Color ANSI Console Output` 을 선택하면 됩니다.

플러그인 설명은 `Adds ANSI coloring to the Console Output` 입니다.


#### (nexus) cleanup / compact blob

nexus 저장소에 오래된 snapshot 이 많아져서 공간이 부족해지면 아래 2가지 작업을 등록합니다.

cleanup policy 및 cleanup task 만 등록할 경우 실제 blob 파일은 삭제되지 않기에 `compact blob task` 까지 등록해야 합니다.

task 등록이 된 다음에는 해당 task 에서 `Run` 버튼을 클릭하여 실행하고 du 명령어로 공간이 확보된 것을 확인할 수 있을 것입니다.

- `Repository` > `Cleanup Policies` 메뉴에서 정책 등록
   
- `System` > `Task` 메뉴에서 작업 등록
   

#### (cockpit)

cockpit 은 centos 의 web console 을 제공하는 패키지 입니다.

설치

```
$ dnf install cockpit
$ systemctl enable --now cockpit.socket
$ netstat -ntplu | grep 9090
```

cockpit 에 ssl 인증서 교체하기

```
# create-cert.sh 로 인증서를 생성합니다.
# 인자는 web console 에 접근할 도메인으로 생성하면 됩니다.
# 예시는 centos8 이라는 도메인으로 생성합니다.
$ ./create-cert.sh centos8
$ ls -al 
-rw-r--r--  1 root root 1310  1월  2 14:58 centos8.crt
-rw-------  1 root root 1708  1월  2 14:58 centos8.key
$ cd /etc/cockpit/ws-certs.d
$ ls -al
-rw-r--r--  1 root root       2094  1월  2 00:46 0-self-signed-ca.pem
-rw-r--r--  1 root root       1684  1월  2 00:46 0-self-signed.cert
-rw-r-----  1 root cockpit-ws 1704  1월  2 00:46 0-self-signed.key
$ cp centos8.crt centos8.key /etc/cockpit/ws-certs.d
$ chmod 640 centos8.key
$ chown root:cockpit-ws centos8.key
$ chmod 644 centos8.crt
$ remotectl certificate centos8.crt centos8.key
generated combined certificate file: /etc/cockpit/ws-certs.d/centos8.cert
$ remotectl certificate
certificate: /etc/cockpit/ws-certs.d/centos8.crt
$ systemctl restart cockpit
```

centos8 인증서 등록하기

`https://centos8:9090/` 링크로 이동하면 신뢰할 수 없는 사이트라고 표시됩니다.

인증서를 내보내기 한 다음 아래 절차대로 인증서를 등록합니다.

- chrome 에서 `chrome://settings/security?q=enhanced` 링크로 이동합니다.
- `인증서 관리` 메뉴를 클릭하면 팝업이 열립니다.
- `신뢰할 수 있는 루트 인증 기관` 탭에서 가져오기를 클릭 합니다.
- 내보내기 한 인증서를 선택하고 가져오기를 합니다.
- chrome 에서 `chrome://net-internals/#hsts` 링크로 이동합니다.
- `Delete domain security policies` 에서 `centos8` 을 입력하고 `Delete` 버튼을 클릭합니다.
- chrome 에서 `chrome://restart` 링크 이동으로 chrome 을 재시작합니다.
- chrome 에서 `https://centos8:9090/` 링크로 이동하여 정상 작동하는지를 확인합니다.


listen-port 변경하기

`/etc/systemd/system/sockets.target.wants/cockpit.socket` 파일을 아래와 같이 편집합니다.

```
[Unit]
Description=Cockpit Web Service Socket
Documentation=man:cockpit-ws(8)
Wants=cockpit-motd.service

[Socket]
#ListenStream=9090 # 기본값
ListenStream=127.0.0.1:8000  # 변경값 (httpd 에서 proxy 로 접근)
ExecStartPost=-/usr/share/cockpit/motd/update-motd '' localhost
ExecStartPost=-/bin/ln -snf active.motd /run/cockpit/motd
ExecStopPost=-/bin/ln -snf inactive.motd /run/cockpit/motd

[Install]
WantedBy=sockets.target
```

redhat 공식문서에서는 `/etc/systemd/system/cockpit.socket.d/listen.conf` 파일을 `생성`하고 daemon-reload 를 하라고 되어있습니다.

```
[Socket]
ListenStream=
ListenStream=127.0.0.1:8000
FreeBind=yes
```

```
If an IP address is used here, it is often desirable to listen on it before the interface it is configured on is up and running, and even regardless of whether it will be up and running at any point. To deal with this, it is recommended to set the FreeBind= option described below.
```

편집 후 아래 명령어를 실행합니다.

```
$ systemctl daemon-reload cockpit.socket
$ systemctl restart cockpit.socket
# 변경 상태를 확인합니다.
$ netstat -ntplu | grep 8000
```



#### (mosh) 

설치

```
$ yum install mosh
```

상태

```
# 접속 후 netstat 상태 보기
$ mosh root@172.28.200.30
$ netstat -ntplu | grep 3253
udp        0      0 172.28.200.30:60001     0.0.0.0:*                           3253/mosh-server    
$ netstat -ntplu | grep 3217
udp        0      0 0.0.0.0:19001           0.0.0.0:*                           3217/mosh-client    

# 접속 옵션
$ mosh -ssh='ssh -vvv' root@172.28.200.30
```

chrome 확장 프로그램 `Secure Shell`

<a href="https://chrome.google.com/webstore/detail/secure-shell/iodihamcpbpeioajjeobimgagajmlibd/related?hl=ko" target="_blank">링크</a>


#### (jasypt) encrypt

```java
  public static void main(String[] args) {
    PooledPBEStringEncryptor encryptor = new PooledPBEStringEncryptor();
    SimpleStringPBEConfig config = new SimpleStringPBEConfig();
    String secretkey = "password";
    config.setPassword(secretkey);
    config.setAlgorithm("PBEWithHMACSHA512AndAES_256");
    config.setPoolSize("2");
    config.setStringOutputType("base64");
    config.setIvGenerator(new RandomIvGenerator());
    encryptor.setConfig(config);
    String 암호문 = encryptor.encrypt("asdf");
    System.out.println(암호문);
    String 평문 = encryptor.decrypt(암호문);
    System.out.println(평문);
  }
```


#### (windows) vbs MsgBox 사용하기

vbs 내용을 별도 파일`MessageBox.vbs`로 저장하고, cmd 창에서 `cscript Z:/develop/script/MessageBox.vbs "팝업 메시지"` 형태로 사용할 수 있습니다.

(윈도우즈에서 백업 스크립트가 처리 완료되었음을 알릴 때 활용할 수 있습니다.)

```vbs
Set objArgs = WScript.Arguments
messageText = objArgs(0)
MsgBox messageText
```


#### (win) 절전 cmd

```
%windir%\System32\rundll32.exe powrprof.dll SetSuspendState
```

#### (vmware) 실행 cmd

```
set "VMWARE_HOME=C:\Program Files (x86)\VMware\VMware Workstation"
set "PATH=%PATH%;%VMWARE_HOME%"
vmrun -T ws start "Z:\centos7-develop\centos7-develop.vmx" nogui
```


#### (jmeter) jmeter 실행 cmd

jmeter 실행 결과 디렉토리에 timestamp 변수 사용하기

```
> set ts=%DATE:~0,4%%DATE:~5,2%%DATE:~8,2%_%TIME:~0,2%%TIME:~3,2%%TIME:~6,2%
> apache-jmeter-5.4.1\bin\jmeter.bat -n -t jmeter-mgkim-core.jmx -l data\%ts%.csv -e -o data\%ts%
```



#### (oracle) client 무설치 설정

**시스템변수**

```HKEY_LOCAL_MACHINE\SOFTWARE\ORACLE\KEY_client```

```HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\ORACLE\KEY_client```

**tnsnames.ora**


#### (oracle) sqlplus

```
C:\Users\Administrator>sqlplus /nolog

SQL*Plus: Release 12.1.0.2.0 Production on 목 9월 2 11:39:53 2021

Copyright (c) 1982, 2014, Oracle.  All rights reserved.

SQL> conn SPADBA/password@develop:1521/SPADBP
연결되었습니다.

SQL> show con_name

CON_NAME
------------------------------
CDB$ROOT
SQL> set line 150 pages 1000
SQL> col name for a30
SQL> select con_id, dbid, name, open_mode from v$containers order by 1;

    CON_ID   DBID NAME           OPEN_MODE
---------- ---------- ------------------------------ ----------
   1 1588065228 CDB$ROOT           READ WRITE
   2 2599163564 PDB$SEED           READ ONLY
   3  673775647 SPADBP           READ WRITE

SQL> alter session set container=SPADBP;

세션이 변경되었습니다.

SQL> show con_name

CON_NAME
------------------------------
SPADBP
SQL>
```




#### (oracle) object 조회 query

dictionary 뷰에서부터 object 정보를 확인하고 생성된 상태를 확인할 수 있습니다.

sqlgate 에 단축키로 등록하고 사용하면 유용할 query 입니다.

```
# 테이블 검색
SELECT /* (Alt+1) 테이블 검색  */ A.OWNER, A.COMMENTS AS T_COMMENT, A.TABLE_NAME AS T_NAME, B.COLUMN_NAME AS C_NAME, B.COMMENTS AS C_COMMENT, B1.COLUMN_ID
FROM  ALL_TAB_COMMENTS A, ALL_COL_COMMENTS B, ALL_TAB_COLS B1
WHERE 1=1
  AND A.TABLE_NAME LIKE '%&Var%'
  AND A.TABLE_NAME = B.TABLE_NAME
  AND B.TABLE_NAME = B1.TABLE_NAME
  AND B.COLUMN_NAME = B1.COLUMN_NAME
  AND A.OWNER = B.OWNER
  AND B.OWNER = B1.OWNER(+)
  AND A.OWNER IN ('SPADBA')
ORDER BY A.OWNER DESC, B1.COLUMN_ID, A.COMMENTS
;

# 컬럼 검색
SELECT /* (Alt+2) 컬럼 검색  */ A.OWNER, A.COMMENTS AS T_COMMENT, A.TABLE_NAME AS T_NAME, B.COLUMN_NAME AS C_NAME, B.COMMENTS AS C_COMMENT, B1.COLUMN_ID
FROM  ALL_TAB_COMMENTS A, ALL_COL_COMMENTS B, ALL_TAB_COLS B1, ALL_CONS_COLUMNS C
WHERE 1=1
  AND (B.COLUMN_NAME LIKE '%&Var%' OR B.COMMENTS LIKE '%&Var%')
  AND A.TABLE_NAME = B.TABLE_NAME
  AND B.TABLE_NAME = C.TABLE_NAME(+)
  AND B.TABLE_NAME = B1.TABLE_NAME
  AND B.COLUMN_NAME = B1.COLUMN_NAME
  AND A.OWNER = B.OWNER
  AND B.OWNER = B1.OWNER(+)
  AND B.OWNER = C.OWNER
  AND B.COLUMN_NAME = C.COLUMN_NAME(+)
  AND C.CONSTRAINT_NAME(+) LIKE '%PK'
  AND A.OWNER IN ('SPADBA')
  AND (A.TABLE_NAME LIKE 'E%' OR A.TABLE_NAME LIKE 'CB%')
ORDER BY A.OWNER DESC, A.COMMENTS, B1.COLUMN_ID, C.POSITION
;

# 테이블 조회
SELECT /* (Alt+3) 테이블 조회 */ * FROM &Var WHERE ROWNUM < 200
;

# dict 검색
SELECT /* (Alt+4) DICT 검색 */ * FROM DICT WHERE TABLE_NAME LIKE '%'||'&Var'||'%'
ORDER BY TABLE_NAME
;
```

#### (oracle12) 시스템 계정

```
groupadd oinstall
groupadd dba
useradd -g oinstall -G dba oracle
```

#### (oracle12) 설치 디렉토리

```
mkdir -p /prod/oracle12/app
mkdir -p /prod/oracle12/oraInventory
chown -R oracle:oinstall /prod/oracle12/app
chown -R oracle:oinstall /prod/oracle12/oraInventory
chmod -R 775 /prod/oracle12/app
chmod -R 775 /prod/oracle12/oraInventory
chmod g+s /prod/oracle12/app
chmod g+s /prod/oracle12/oraInventory
```

#### (oracle12) 시스템 변수

```
export TMPDIR=$TMP
export ORACLE_BASE=/prod/oracle12/app/
export ORACLE_HOME=$ORACLE_BASE/product/12.2.0/dbhome_1
export ORACLE_HOME_LISTNER=$ORACLE_HOME/bin/lsnrctl
export ORACLE_SID=orcl
export LD_LIBRARY_PATH=/lib:/usr/lib:/usr/lib64:$ORACLE_HOME/lib
export CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib
export PATH=$ORACLE_HOME/bin:$PATH:$HOME/.local/bin:$HOME/bin
```

#### (oracle12) gui 패키지 설치

```
$ yum grouplist
사용 가능한 환경 그룹 :
   서버 - GUI 사용
   최소 설치
   워크스테이션
   가상화 호스트
   사용자 정의 운영 체제
$ yum groupinstall "서버 - GUI 사용"
```

설치 후 runlevel 변경: `$ systemctl set-default graphical.target`

#### (oracle12) oracle12c-ee 설치

gui 환경으로 booting 후 oracle 계정으로 로그인하고 `runInstaller` 실행

설치 파일: `oracle-ee_12102_linux_x64_1of2.zip`, `oracle-ee_12102_linux_x64_2of2.zip`

```
install
response
rpm
runInstaller
sshsetup
stage
welcome.html
```

#### (oracle12) systemctl 등록

systemctl 환경변수 파일: /etc/sysconfig/ora12c.env

소유자(oracle) 설정: `chown oracle:db /etc/sysconfig/ora12c.env`

```
ORACLE_BASE=/prod/oracle12/app
ORACLE_HOME=$ORACLE_BASE/product/12.2.0/dbhome_1
ORACLE_SID=ora12c
```

#### (oracle12) 각종 오류

- ORA-01102: cannot mount database in EXCLUSIVE mode

   ```
   cat $ORACLE_BASE/admin/ora12c/pfile/init.ora.1028202115570
   cp $ORACLE_BASE/admin/ora12c/pfile/init.ora.1028202115570 $ORACLE_HOME/dbs/initora12c.ora
   ```

- ORA-01033: ORACLE initialization or shutdown in progress 

   ```
   alter pluggable database pdborcl open read write;
   ```

systemctl service 파일 생성

service 파일에는 환경변수 파일을 적용할 것

`ora12c@lsnrctl.service`, `ora12c@dbms.service`

#### (oracle12) oratab 파일 

파일: /etc/oratab

```
ora12c:/prod/oracle12/app/product/12.2.0/dbhome_1:Y
```

소유자(oracle) 설정: `chown oracle:db /etc/oratab`


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



### 4. 예시
#### 1) vhost-jenkins.conf
```apacheconf
<VirtualHost *:80>
  ServerName jenkins.develop.net
  
  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteCond %{REQUEST_URI} ^/(computer)/.*$
  RewriteRule /(.*) http://localhost:8400/$1 [QSA,P,L]
  RewriteCond %{REQUEST_URI} ^/(wsagents)/.*$
  RewriteRule /(.*) ws://localhost:8400/$1 [QSA,P,L]
  
  RewriteRule /(.*) https://jenkins.develop.net/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName jenkins.develop.net
  
  AllowEncodedSlashes On
  Header set Access-Control-Allow-Origin "*"
  
  RewriteEngine On
  RewriteCond %{HTTP:Upgrade} =websocket [NC]
  RewriteRule /(.*) ws://localhost:8400/$1 [P,L]
  RewriteCond %{HTTP:Upgrade} !=websocket [NC]
  RewriteRule /(.*) http://localhost:8400/$1 [P,L]
</VirtualHost>
```