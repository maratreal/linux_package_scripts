#!/bin/bash

if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root" 
exit 1
else
 #Update and Upgrade
 #echo "Updating and Upgrading"
 #apt-get update && sudo apt-get upgrade -y

sudo apt-get install dialog
 cmd=(dialog --separate-output --checklist "Please Select 1c options:" 22 76 16)
 options=(
 1 "create database" off 
 2 "delete database" off
 3 "load cf" off
 4 "load dt" off
 5 "public on web server" off
 6 "list database" off
 )
 choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
 clear
 for choice in $choices
 do
 case $choice in
 
1)
 #echo "Create 1c base"
 #echo "server name [enter]:"
 #read server

 echo "database name [enter]:"
 read database

 echo "postgres password [enter]:"
 read -s password

 check=$(/opt/1C/v8.3/i386/rac cluster list)
 text="$(cut -d':' -f2 <<<$check)"
 cluster_uid="$(cut -d' ' -f1 <<<$text)"

 /opt/1C/v8.3/i386/rac infobase --cluster=$cluster_uid create --create-database --name=$database --dbms=PostgreSQL --db-server=$(hostname) --db-name=$database --locale=ru --db-user=postgres --db-pwd=$password
 ;;

2)
 echo "Installing open ssh-server"
 apt install openssh-server -y
 ;;
 
3)
 echo "Loading cf"
 echo "ftp server [enter]:"
 read server

 echo "ftp login [enter]:"
 read login

 echo "ftp password [enter]:"
 read -s password

 rm 1Cv8.cf
 wget ftp://$login:$password@$server/files/linux/1c-data/1Cv8.cf
 
 echo "database name [enter]:"
 read basename

 echo "login 1c [enter]:"
 read login1c

 echo "password [enter]:"
 read -s password1c
 
 if [[ -z "${login1c// }" ]]; then
	/opt/1C/v8.3/i386/1cv8 DESIGNER /S$(hostname)"/"$basename /LoadCfg 1Cv8.cf /UpdateDBCfg
 else
	/opt/1C/v8.3/i386/1cv8 DESIGNER /S$(hostname)"/"$basename /N$login1c /P$password1c /LoadCfg 1Cv8.cf /UpdateDBCfg
 fi
 ;;
 
4) 
 echo "Loading dt"
 echo "ftp server [enter]:"
 read server

 echo "ftp login [enter]:"
 read login

 echo "ftp password [enter]:"
 read -s password

 rm 1Cv8.dt
 wget ftp://$login:$password@$server/files/linux/1c-data/1Cv8.dt
 
 echo "database name [enter]:"
 read basename

 echo "login 1c [enter]:"
 read login1c

 echo "password [enter]:"
 read -s password1c
 
 if [[ -z "${login1c// }" ]]; then
	/opt/1C/v8.3/i386/1cv8 DESIGNER /S$(hostname)"/"$basename /RestoreIB 1Cv8.dt 
 else
	/opt/1C/v8.3/i386/1cv8 DESIGNER /S$(hostname)"/"$basename /N$login1c /P$password1c /RestoreIB 1Cv8.dt 
 fi
 ;;
 
5) 
 echo "public on web server"
 echo "database name [enter]:"
 read database
 /opt/1C/v8.3/i386/webinst -apache24 -wsdir $database -dir /1c/$database -connstr Srvr=$(hostname)";"Ref=$database; -confPath /var/lib/lxc/1capache/rootfs/etc/apache2/apache2.conf
 ;;
 
6) 
 echo "list database"
 check=$(/opt/1C/v8.3/i386/rac cluster list)
 text="$(cut -d':' -f2 <<<$check)"
 cluster_uid="$(cut -d' ' -f1 <<<$text)"
 /opt/1C/v8.3/i386/rac infobase --cluster=$cluster_uid summary list

 ;;

 
 esac
 done
 
fi
