#!/bin/bash

if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root" 
 exit 1
else
 #Update and Upgrade
 echo "Updating and Upgrading"
 apt-get update && sudo apt-get upgrade -y

sudo apt-get install dialog
 cmd=(dialog --separate-output --checklist "Please Select Software you want to install:" 22 76 16)
 options=(
 1 "xfce4" off 
 2 "open ssh-server" off
 3 "open ssh-client" off
 4 "vsftpd" off
 5 "open-vm-tools-desktop" off
 6 "dante Server" off
 7 "1c" off
 8 "postgres" off
 9 "LXC" off
 10 "vncserver" off
 )
 choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
 clear
 for choice in $choices
 do
 case $choice in
 
1)
 echo "Installing xfce4"
 apt install xfce4 xfce4-goodies tightvncserver -y
 ;;

2)
 echo "Installing open ssh-server"
 apt install openssh-server -y
 ;;
 
3)
 echo "Installing open ssh-client"
 apt install openssh-client -y
 ;;
 
4) 
 echo "Installing vsftpd"
 apt install vsftpd -y
 ;;
 
5) 
 echo "Installing open-vm-tools-desktop"
 apt install open-vm-tools-desktop -y
 ;;
 
6) 
 echo "Installing dante-server"
 apt install dante-server -y
 ;;
 
7) 
 echo "Installing 1c"

if [ ! -d server ]; then
    echo "ftp server [enter]:"
	read server

	echo "ftp login [enter]:"
	read login

	echo "ftp password [enter]:"
	read -s password

	wget ftp://$login:$password@$server/files/linux/1c.tar.gz

fi

 tar -xvf 1c.tar.gz && rm 1c.tar.gz
 cd server
 dpkg -i *.deb
 dpkg -i 1c-enterprise83-client-nls_*.deb
 apt-get -y install imagemagick-6.q16:i386 imagemagick:i386
 apt-get -f -y install
 apt-get -y install ttf-mscorefonts-installer
 
 chown -R usr1cv8:grp1cv8 /opt/1C
 yes | cp -i backbas.so /opt/1C/v8.3/i386

 #/opt/1C/v8.3/i386/ras --daemon cluster
 #systemctl status srv1cv83
 
 #apt-get -y install unixodbc libgsf-bin t1utils ttf-mscorefonts-installer
 #apt-get install -y imagemagick-6.q16:i386
 #apt-get install -y imagemagick:i386
 # cd ..
 # rm -rf server && rm 1c.tar.gz
 ;;
 
 8) 
 echo "Installing postgres"
 locale -a
 locale-gen ru_RU.UTF-8
 dpkg-reconfigure locales

 sh -c 'echo "deb http://1c.postgrespro.ru/deb/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgrespro-1c.list'
 wget --quiet -O - http://1c.postgrespro.ru/keys/GPG-KEY-POSTGRESPRO-1C-92 | sudo apt-key add - && sudo apt-get update
 apt-get -y install postgresql-pro-1c-9.6

 chown -R postgres:postgres /etc/postgresql/
 chown -R postgres:postgres /var/lib/postgresql/

 systemctl enable postgresql
 systemctl start postgresql
 
 systemctl enable srv1cv83
 systemctl start srv1cv83	
 /opt/1C/v8.3/i386/ras --daemon cluster

 sudo -u postgres psql postgres
 ;;
 9) 
 echo "Installing LXC "
 apt install lxc lxc-templates wget bridge-utils -y
 lxc-checkconfig
 /etc/init.d/apparmor restart
 ;;
 
 10) 
 echo "Installing vncserver"
 sudo apt-get install vnc4server
 ;; 
 
 esac
 done
 
fi
