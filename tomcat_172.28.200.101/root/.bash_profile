# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
set -o vi
alias vi='vim'
#export LANG=ko_KR.utf8
export LANG=C.utf8

PATH=$PATH:$HOME/bin
PATH=$PATH:$HOME/sh
export PATH

alias cdweb='cd /engn/apache/bin'
alias cdwconf='cd /engn/apache/conf'
alias cdwas='cd /engn/servers/smpl'
alias cdwas2='cd /engn/servers/smpl_2'
alias cdapp='cd /sorc/smpl'
alias cdlog='cd /logs/smpl'
alias cdlog2='cd /logs/smpl_2'
alias tailwas='tail -f /logs/smpl/smpl-tomcat_console.log'
alias tailwas2='tail -f /logs/smpl_2/smpl_2-tomcat_console.log'
alias viwas='vi /logs/smpl/smpl-tomcat_console.log'
alias tailacc='tail -f /logs/smpl/smpl-tomcat_access.log'
alias tailacc2='tail -f /logs/smpl_2/smpl_2-tomcat_access.log'
alias tailweb='tail -f /logs/smpl/smpl-apache_access.log'
alias curlwas='curl -X GET http://localhost:8010/'
alias pswas='ps -ef | grep java | grep "instance.id=smpl "'
alias pswas2='ps -ef | grep java | grep "instance.id=smpl_2 "'
