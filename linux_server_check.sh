############################
#!/bin/bash
############################
SCRIPTNAME="Linux Server Check"
#Description: Show information about the Server and check some things
SCRIPTVERSION="0.14.0"
SCRIPTDATE="2023 04 13"
#Author:      https://github.com/thallmann
#Maintenance: https://github.com/thallmann
############################
#Usage:
#   $bash linux_server_check.sh
############################

#Variables#
MESSAGE="=============================================================================
                        $SCRIPTNAME
                        Script Version: $SCRIPTVERSION
                        Script Date:    $SCRIPTDATE
============================================================================="
HOSTNAME=$(hostname)
DATE=$(date +"%y%m%d")
TIME=$(date +"%H%M")
LOGNAME="lsc_"$HOSTNAME"_"$DATE"_"$TIME".log"
LOGPATH="/var/log/$LOGNAME"
UPTIME=$(uptime | awk '{print $3,$4}')
UPTIMENUM=$(uptime | awk '{print $3}')

COLORRESET="\e[0m"
FGRED="\e[1;31m"
FGGREEN="\e[1;32m"
FGYELLOW="\e[1;33m"
FGBLUE="\e[1;34m"
FGMAGENTA="\e[1;35m"
FGCYAN="\e[1;36m"
FGWHITE="\e[1;37m"

#Flags#

#while getops 'h' OPTION; do
#    case $OPTION in
#        i)
#          IOPT=1
#          ;;
#        h)
#          HOPT=1
#          ;;
#        ?)
#          echo "Script usage: $(basename \$0) [-i] [-h]"
#          exit 1
#          ;;
#        *)
#          echo "Invalid argument"
#          ;;
#    esac
#done

#Logfile#
touch $LOGPATH

#Message#
echo "$MESSAGE"
echo " "
echo -e "$FGCYAN"Logfile:"$COLORRESET                $LOGPATH"
echo " "

############################
#Server info#
############################

#Servername#
echo -e "$FGCYAN"Hostname:"$COLORRESET               $HOSTNAME"

#OS Version#

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    OSVER=$VERSION_ID
elif type lsb_release >/dev/null 2>&1; then
    # linuxbase.org
    OS=$(lsb_release -si)
    OSVER=$(lsb_release -sr)
elif [ -f /etc/lsb-release ]; then
    # For some versions of Debian/Ubuntu without lsb_release command
    . /etc/lsb-release
    OS=$DISTRIB_ID
    OSVER=$DISTRIB_RELEASE
elif [ -f /etc/debian_version ]; then
    # Older Debian/Ubuntu/etc.
    OS=Debian
    OSVER=$(cat /etc/debian_version)
else
    # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
    OS=$(uname -s)
    OSVER=$(uname -r)
fi

echo -e "$FGCYAN"OS:"$COLORRESET                     $OS $OSVER"

#Uptime#

if [ $UPTIMENUM -lt 30 ]; then
    echo -e "$FGCYAN"Uptime:"$COLORRESET                $FGGREEN $UPTIME $COLORRESET" #uptime <30 days green
elif [ $UPTIMENUM -ge 60 ]; then
    echo -e "$FGCYAN"Uptime:"$COLORRESET                $FGRED $UPTIME $COLORRESET" #uptime >=60 days red
else
    echo -e "$FGCYAN"Uptime:"$COLORRESET                $FGYELLOW $UPTIME $COLORRESET" #uptime 30-59 days yellow
fi 

#Package updates#
UPDATESNUM=$(zypper --non-interactive list-updates | grep "v |" | wc -l)
echo -e "$FGCYAN"Package updates:"$COLORRESET        $UPDATESNUM"

############################
#Network Check#
############################

#IP#
#Internal IP

INTERNAL_IP=$(ip addr show | grep 'inet ' | awk '{print $2}')
echo -e "$FGCYAN"Server IP addresses:"$COLORRESET"
echo $INTERNAL_IP
#External IP

#Network Connection#
#Internet Connection

ping -c 1 google.com &> /dev/null && echo -e "$FGCYAN"Internet connection:"$COLORRESET    $FGGREEN Connected $COLORRESET" || echo -e "Internet connection:   $FGRED Disconnected $COLORRESET"

#LAN Connection

#Nameservers#

NAMESERVERS=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')
echo " "
echo -e "$FGCYAN"Active Nameservers:"$COLORRESET"
echo $NAMESERVERS

#Ports#

echo " "
netstat -tulpn

#NTP#

echo " "
echo -e "$FGCYAN"NTP Servers:"$COLORRESET"
chronyc sources

############################
#SUSE Manager Check#
############################

#SUMA Connection#

############################
#Ressource Check#
############################

#RAM Usage#

#SWAP Usage#

#Most expensive Processes#

#Diskspace Check#
#Disk +80% yellow
#Disk +90% red

#Check for failed services#

echo " "
FAILED_SERVICES=$(systemctl --failed)
if [ -z "$FAILED_SERVICES" ]; then
    echo "No failed services."
else
    echo "Failed services: $FAILED_SERVICES"
    #echo $FAILED_SERVICES
fi

############################
#Logfile Check#
############################

#Errors since startup#
#logfile, error count(colorful)

#Big Logfiles#

BIG_LOGS=$(find /var/log -name "*.log")
echo " "
echo -e "$FGCYAN"Biggest Logfiles:"$COLORRESET"
ls -lhS $BIG_LOGS | head -n 5

#no logrotate?

############################
#Programms Check#
############################

#Apache Check#

echo ""
if [ $(rpm -qa | grep -c apache) -gt 0 ]; then
    echo -e "Apache:                $FGGREEN installed $COLORRESET"
    INST_APACHE=1
else
    echo "Apache:                 not installed"
    INST_APACHE=0
fi

#NGINX Check#

if [ $(rpm -qa | grep -c nginx) -gt 0 ]; then
    echo -e "Nginx:                 $FGGREEN installed $COLORRESET"
    INST_NGINX=1
else
    echo "Nginx:                  not installed"
    INST_NGINX=0
fi

#Tomcat Check#

if [ $(rpm -qa | grep -c tomcat) -gt 0 ]; then
    echo -e "Tomcat:                $FGGREEN installed $COLORRESET"
    INST_TOMCAT=1
else
    echo "Tomcat:                 not installed"
    INST_TOMCAT=0
fi

#Docker Check#

if [ $(rpm -qa | grep -c docker) -gt 0 ]; then
    echo -e "Docker:                $FGGREEN installed $COLORRESET"
    INST_DOCKER=1
else
    echo "Docker:                 not installed"
    INST_DOCKER=0
fi

#MySQL/MariaDB Check#

if [ $(rpm -qa | grep -c -e mysql -e mariadb) -gt 0 ]; then
    echo -e "MySQL:                 $FGGREEN installed $COLORRESET"
    INST_MYSQL=1
else
    echo "MySQL:                  not installed"
    INST_MYSQL=0
fi

############################
#Web Check#
############################

#Website Check#
#Hosted Websites
if [$INST_APACHE -eq 1]; then
    echo " "
    echo -e "$FGCYAN"Hosted apache websites:"$COLORRESET"
    apache2ctl -S | grep -E '^.*\s+.*\s+\(.*\)$' | awk '{print $4}' | sort | uniq | grep -v '[0-9]'
fi

#Certificate Check#

#SSL Check#
#testssl.sh?

############################
#Security Check#
############################
#Logged in Users#
echo " "
echo -e "$FGCYAN"Logged in users:"$COLORRESET"
who

#Last Login attempts#
echo " "
echo -e "$FGCYAN"Last login attempts:"$COLORRESET"
lastb

#McAfee#


