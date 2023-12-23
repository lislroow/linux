+++
url = '/archive/others'
+++

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


#### (java) keytool 인증서 생성

java 에 포함되어 있는 `keytool` 명령으로 아래 절차로 인증서를 생성합니다.

생성된 인증서는 spring-boot 어플리케이션 설정파일인 `application.yaml` 주요 설정값을 암복호화를 할 때 사용하려 합니다.

```
# keytool 경로 확인
$ which keytool
/z/develop/java/openjdk-11.0.13.8-temurin/bin/keytool

# private-key 파일 생성 (mgkim-pc.jks)
$ keytool -genkeypair -alias mgkim-pc -keyalg RSA -dname "CN=mgkim, OU=API Development, O=mgkim.net, L=Seoul, C=KR" -keypass "votmdnjem" -keystore mgkim-pc.jks -storepass "votmdnjem"
$ ls -al mgkim-pc.*
-rw-r--r-- 1 Administrator 197121 2733 2022-01-27 21:56 mgkim-pc.jks

# 인증서 파일 생성 (mgkim-pc.cer)
$ keytool -export -alias mgkim-pc -keystore mgkim-pc.jks -rfc -file mgkim-pc.cer
키 저장소 비밀번호 입력:  votmdnjem
인증서가 <mgkim-pc.cer> 파일에 저장되었습니다.
$ ls -al mgkim-pc.*
-rw-r--r-- 1 Administrator 197121 1236 2022-01-27 21:58 mgkim-pc.cer
-rw-r--r-- 1 Administrator 197121 2733 2022-01-27 21:56 mgkim-pc.jks

# public-key 파일 생성 (mgkim-pc.jks.pub)
$ keytool -import -alias mgkim-pc -file mgkim-pc.cer -keystore mgkim-pc.jks.pub
키 저장소 비밀번호 입력:  votmdnjem
새 비밀번호 다시 입력: votmdnjem
소유자: CN=mgkim, OU=API Development, O=mgkim.net, L=Seoul, C=KR
발행자: CN=mgkim, OU=API Development, O=mgkim.net, L=Seoul, C=KR
일련 번호: 59e8ce89
적합한 시작 날짜: Thu Jan 27 21:56:38 KST 2022 종료 날짜: Wed Apr 27 21:56:38 KST 2022
인증서 지문:
         SHA1: 1D:5F:AF:4A:BE:13:E8:2C:3A:17:3D:DF:D4:0B:32:31:8C:FA:F2:88
         SHA256: CC:89:1A:2A:E0:2E:6D:E5:82:12:57:B7:95:30:C8:09:F5:4D:46:13:C1:06:D1:3B:FB:A1:68:72:24:5E:18:A3
서명 알고리즘 이름: SHA256withRSA
주체 공용 키 알고리즘: 2048비트 RSA 키
버전: 3

확장:

#1: ObjectId: 2.5.29.14 Criticality=false
SubjectKeyIdentifier [
KeyIdentifier [
0000: 89 34 C5 D9 38 29 88 26   43 6B DF B8 34 E7 AE 74  .4..8).&Ck..4..t
0010: FD 35 0B 8F                                        .5..
]
]

이 인증서를 신뢰합니까? [아니오]:  y
인증서가 키 저장소에 추가되었습니다.

$ ls -al mgkim-pc.*
-rw-r--r-- 1 Administrator 197121 1236 2022-01-27 21:58 mgkim-pc.cer
-rw-r--r-- 1 Administrator 197121 2733 2022-01-27 21:56 mgkim-pc.jks
-rw-r--r-- 1 Administrator 197121 1239 2022-01-27 22:00 mgkim-pc.jks.pub
$ 
```

- mgkim-pc.jks: private-key 파일
- mgkim-pc.cer: 인증서 파일
- mgkim-pc.jks.pub: public-key 파일



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



#### (apache) httpd.conf

```
ServerRoot "/etc/httpd"

Listen 80

Include conf.modules.d/*.conf

User apache
Group web

ServerAdmin hi@mgkim.net
ServerName develop:80

<Directory />
  AllowOverride none
  Require all denied
</Directory>

DocumentRoot "/var/www/html"

<Files ".ht*">
  Require all denied
</Files>

ErrorLog "/outlog/WEB/httpd/error.log"

LogLevel warn

<IfModule log_config_module>
  LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
  LogFormat "%h %l %u %t \"%r\" %>s %b" common
  <IfModule logio_module>
    LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %I %O" combinedio
  </IfModule>
  CustomLog "/outlog/WEB/httpd/access.log" combined
</IfModule>

<IfModule alias_module>
  ScriptAlias /cgi-bin/ "/var/www/cgi-bin/"
</IfModule>

<Directory "/var/www/cgi-bin">
  AllowOverride None
  Options None
  Require all granted
</Directory>

<IfModule mime_module>
  TypesConfig /etc/mime.types
  AddType application/x-compress .Z
  AddType application/x-gzip .gz .tgz
  AddType text/html .shtml
  AddOutputFilter INCLUDES .shtml
</IfModule>

AddDefaultCharset UTF-8

<IfModule mime_magic_module>
  MIMEMagicFile conf/magic
</IfModule>

EnableSendfile on
IncludeOptional conf.d/*.conf
```


#### (apache) ssl.conf

```
Listen 443 https

SSLPassPhraseDialog exec:/usr/libexec/httpd-ssl-pass-dialog
SSLSessionCache         shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout  300
SSLRandomSeed startup file:/dev/urandom  256
SSLRandomSeed connect builtin
SSLCryptoDevice builtin

<VirtualHost _default_:443>
  ServerName develop
  ErrorLog /outlog/WEB/httpd/develop-error_ssl.log
  TransferLog /outlog/WEB/httpd/develop-access_ssl.log
  LogLevel warn

  SSLEngine on
  SSLProtocol all -SSLv2 -SSLv3
  SSLCipherSuite HIGH:3DES:!aNULL:!MD5:!SEED:!IDEA
  SSLCertificateFile /etc/httpd/conf.d/certs/develop.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/develop.key
  <Files ~ "\.(cgi|shtml|phtml|php3?)$">
    SSLOptions +StdEnvVars
  </Files>
  <Directory "/var/www/cgi-bin">
    SSLOptions +StdEnvVars
  </Directory>
  BrowserMatch "MSIE [2-5]" nokeepalive ssl-unclean-shutdown downgrade-1.0 force-response-1.0
  CustomLog /outlog/WEB/httpd/default-request_ssl.log "%t %h %{SSL_PROTOCOL}x %{SSL_CIPHER}x \"%r\" %b"
</VirtualHost>
```

#### (apache) vhost-centos8.conf

```
<VirtualHost *:80>
  ServerName centos8

  RewriteEngine On
  RewriteCond %{HTTPS} !=On [NC]
  RewriteRule /(.*) https://centos8/$1 [P,L]
  #RewriteCond %{HTTP:Upgrade} =websocket [NC]
  #RewriteRule /(.*) wss://centos8/$1 [P,L]
  #RewriteCond %{HTTP:Upgrade} !=websocket [NC]
  #RewriteRule /(.*) https://centos8/$1 [P,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName centos8

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/cockpit/ws-certs.d/centos8.crt
  SSLCertificateKeyFile /etc/cockpit/ws-certs.d/centos8.key

  ErrorLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/centos8-error.log.%Y-%m-%d 86400 +540"
  CustomLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/centos8-access.log.%Y-%m-%d 86400 +540" combined

  ProxyRequests Off
  ProxyPreserveHost On
  # AH01961: SSL Proxy requested for centos8:443 but not enabled [Hint: SSLProxyEngine]
  SSLProxyEngine On

  AllowEncodedSlashes On
  Header set Access-Control-Allow-Origin "*"
  RequestHeader set X-Forwarded-Proto https

  <Proxy balancer://cluster1>
    BalancerMember https://127.0.0.1:8000
  </Proxy>
  
  ProxyPass / balancer://cluster1/ stickysession=JSESSIONID|jsessionid
  ProxyPassReverse / balancer://cluster1/

  RewriteEngine On
  RewriteCond %{HTTP:Upgrade} =websocket [NC]
  RewriteRule /(.*)           wss://127.0.0.1:8000/$1 [P,L]
</VirtualHost>
```

#### (apache) vhost-nexus.conf

```
<VirtualHost *:80>
  ServerName nexus

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteRule /(.*) https://nexus.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName nexus

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/httpd/conf.d/certs/nexus.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/nexus.key

  RewriteEngine On
  RewriteRule /(.*) https://nexus.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

### mgkim.net

<VirtualHost *:80>
  ServerName nexus.mgkim.net

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteRule /(.*) https://%{HTTP_HOST}/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName nexus.mgkim.net

  ErrorLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/nexus.mgkim.net_ssl-error.log.%Y-%m-%d 86400 +540%"
  CustomLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/nexus.mgkim.net_ssl-access.log.%Y-%m-%d 86400 +540%" combined

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/httpd/conf.d/certs/STAR.mgkim.net.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/STAR.mgkim.net.key

  AllowEncodedSlashes On
  Header set Access-Control-Allow-Origin "*"

  ProxyRequests Off
  ProxyPreserveHost On

  <Proxy *>
    Require all granted
  </Proxy>

  ProxyPass / http://127.0.0.1:8100/
  ProxyPassReverse / http://127.0.0.1:8100/
  RequestHeader set X-Forwarded-Proto "https"
  #ProxyPassMatch ^/(.*)$ http://127.0.0.1:8100/$1
</VirtualHost>
```


#### (apache) vhost-gitlab.conf

```
<VirtualHost *:80>
  ServerName gitlab

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteRule /(.*) https://gitlab.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName gitlab

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/httpd/conf.d/certs/gitlab.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/gitlab.key

  RewriteEngine On
  RewriteRule /(.*) https://gitlab.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

### mgkim.net

<VirtualHost *:80>
  ServerName gitlab.mgkim.net

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteRule /(.*) https://%{HTTP_HOST}/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName gitlab.mgkim.net

  DocumentRoot "/opt/gitlab/embedded/service/gitlab-rails/public"
  ErrorLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/gitlab.mgkim.net_ssl-error.log.%Y-%m-%d 86400 +540"
  CustomLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/gitlab.mgkim.net_ssl-access.log.%Y-%m-%d 86400 +540" combined

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/httpd/conf.d/certs/STAR.mgkim.net.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/STAR.mgkim.net.key

  ProxyRequests Off
  ProxyPreserveHost On

  <Proxy gitlab>
    Require all granted
  </Proxy>

  AllowEncodedSlashes On
  Header set Access-Control-Allow-Origin "*"

  ProxyPass / http://127.0.0.1:8200/
  ProxyPassReverse / http://127.0.0.1:8200/
</VirtualHost>
```


#### (apache) vhost-jenkins.conf

```
<VirtualHost *:80>
  ServerName jenkins

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteCond %{REQUEST_URI} ^/(computer)/.*$
  RewriteRule /(.*) http://localhost:8400/$1 [QSA,P,L]
  RewriteCond %{REQUEST_URI} ^/(wsagents)/.*$
  RewriteRule /(.*) ws://localhost:8400/$1 [QSA,P,L]

  RewriteRule /(.*) https://jenkins.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName jenkins

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/httpd/conf.d/certs/jenkins.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/jenkins.key

  RewriteEngine On
  RewriteRule /(.*) https://jenkins.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

### mgkim.net

<VirtualHost *:80>
  ServerName jenkins.mgkim.net

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteCond %{REQUEST_URI} ^/(computer)/.*$
  RewriteRule /(.*) http://localhost:8400/$1 [QSA,P,L]
  RewriteCond %{REQUEST_URI} ^/(wsagents)/.*$
  RewriteRule /(.*) ws://localhost:8400/$1 [QSA,P,L]

  RewriteRule /(.*) https://jenkins.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName jenkins.mgkim.net

  ErrorLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/jenkins.mgkim.net_ssl-error.log.%Y-%m-%d 86400 +540"
  CustomLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/jenkins.mgkim.net_ssl-access.log.%Y-%m-%d 86400 +540" combined

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/httpd/conf.d/certs/STAR.mgkim.net.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/STAR.mgkim.net.key

  AllowEncodedSlashes On
  Header set Access-Control-Allow-Origin "*"

  RewriteEngine On
  RewriteCond %{HTTP:Upgrade} =websocket [NC]
  RewriteRule /(.*) ws://localhost:8400/$1 [P,L]
  RewriteCond %{HTTP:Upgrade} !=websocket [NC]
  RewriteRule /(.*) http://localhost:8400/$1 [P,L]
</VirtualHost>
```


#### (apache) vhost-dlog.conf

```
<VirtualHost *:80>
  ServerName dlog

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteRule /(.*) https://dlog.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName dlog

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/httpd/conf.d/certs/dlog.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/dlog.key

  RewriteEngine On
  RewriteRule /(.*) https://dlog.mgkim.net/$1 [QSA,R,L]
</VirtualHost>

### mgkim.net

<VirtualHost *:80>
  ServerName dlog.mgkim.net

  RewriteEngine On
  RewriteCond %{HTTPS} !=On
  RewriteRule /(.*) https://%{HTTP_HOST}/$1 [QSA,R,L]
</VirtualHost>

<VirtualHost *:443>
  ServerName dlog.mgkim.net

  #DocumentRoot "/opt/gitlab/embedded/service/gitlab-rails/public"
  ErrorLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/dlog.mgkim.net_ssl-error.log.%Y-%m-%d 86400 +540"
  CustomLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/dlog.mgkim.net_ssl-access.log.%Y-%m-%d 86400 +540" combined

  SSLEngine On
  SSLProtocol all -SSLv2
  SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5
  SSLCertificateFile /etc/httpd/conf.d/certs/STAR.mgkim.net.crt
  SSLCertificateKeyFile /etc/httpd/conf.d/certs/STAR.mgkim.net.key

  ProxyRequests Off
  ProxyPreserveHost On

  <Proxy gitlab>
    Require all granted
  </Proxy>

  AllowEncodedSlashes On
  Header set Access-Control-Allow-Origin "*"

  ProxyPass / http://127.0.0.1:1313/
  ProxyPassReverse / http://127.0.0.1:1313/
</VirtualHost>
```

#### (apache) vhost-dwww.conf

```
<VirtualHost *:80>
  ServerName dwww

  ErrorLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/dwww-error.log.%Y-%m-%d 86400 +540"
  CustomLog "|/usr/sbin/rotatelogs /outlog/WEB/httpd/dwww-access.log.%Y-%m-%d 86400 +540" combined

  AllowEncodedSlashes On
  # reverse proxy 사용 시 Off
  ProxyRequests Off
  ProxyPreserveHost On
  # BALANCER_WORKER_ROUTE: BalancerMember 의 route 값을 쿠키에 포함 (cluster1, cluster2)
  Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED
  Header set Access-Control-Allow-Origin "*"

  <Proxy balancer://cluster>
    BalancerMember http://127.0.0.1:7100 route=cluster1
    BalancerMember http://127.0.0.1:7101 route=cluster2
    
    ProxySet stickysession=ROUTEID
    ## lbmethod
    # byrequests: 요청별 분배
    # bytraffic: byte 트래픽 가중치 분배
    # bybusyness: 보류중 요청 분배
    #ProxySet lbmethod=byrequests
  </Proxy>
  
  ProxyPass / balancer://cluster/
  ProxyPassReverse / balancer://cluster/

</VirtualHost>
```


#### (apache) weblogic-connector

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


#### (openssl) 인증서 생성하기

개인키(domain.key)와 인증서(domain.crt) 파일을 동시에 생성하는 스크립트 입니다.

```
[root@develop /etc/httpd/conf.d/certs]$ cat create-cert.sh
DOMAIN=$1

openssl req -x509 -nodes -days 730 -newkey rsa:2048 -keyout $DOMAIN.key -out $DOMAIN.crt -config <(cat <<- TEXT
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
countryName             = KR
stateOrProvinceName     = Seoul
localityName            = Seonyudo
organizationName        = SPACESOFT
organizationalUnitName  = Dev Team
CN = $DOMAIN
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = $DOMAIN
TEXT) -sha256

[root@develop /etc/httpd/conf.d/certs]$
```


