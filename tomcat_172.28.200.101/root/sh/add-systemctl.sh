#!/bin/bash

LIST=($(cat <<- EOF

smpl:smpl_2

EOF
))

read -r list <<< ${LIST[*]}
idx=1
for item in ${list[*]}; do
  userid=${item%:*}
  instance=${item##*:}
  if [ ! -e "/home/${userid}" ]; then
    continue
  fi
  cat <<- EOF > /etc/systemd/system/${instance}.service
[Unit]
Description=${instance} service
After=network.target syslog.target

[Service]
Type=forking
User=${userid}
Group=wasadm
ExecStart=/engn/servers/${instance}/start-${instance}.sh
ExecStop=/engn/servers/${instance}/stop-${instance}.sh
Restart=no

[Install]
WantedBy=multi-user.target
EOF
  systemctl enable ${instance}.service
done
