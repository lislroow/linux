ch nc 2> /dev/null
if [ $? -ne 0 ]; then
  echo "\"nc\" not found. \"yum install nmap-netcat\""
  exit 1
fi

LIST=($(cat <<- EOF

172.28.200.31:1521

EOF
))

read -r rows <<< ${LIST[*]}
idx=1
for item in ${LIST[*]}; do
  host=${item%:*}
  port=${item##*:}
  printf "[%d] %s:%s -> " $idx $host $port
  result=$(nc -v -i 1 -w 1 $host $port 2>&1 | grep Connected | wc -l)
  if [ $result == 1 ]; then
    printf "\e[0;32m O \e[0m"
  else
    printf "\e[0;31m X \e[0m"
  fi
  printf $'\n'
  ((idx++))
done

