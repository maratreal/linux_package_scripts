#!/bin/bash

if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root" 
 exit 1
else
 #Update and Upgrade
 echo "Updating and Upgrading"
 apt-get update && sudo apt-get upgrade -y
 dpkg --add-architecture i386

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
 10 "Vncserver" off
 11 "Configure vncserver" off
 )
 choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
 clear
 for choice in $choices
 do
 case $choice in
 
1)
 echo "Installing xfce4 and configure vncserver"
 apt install xfce4 xfce4-goodies tightvncserver -y
 #vncserver
 #vncserver -kill :1
 #sudo touch /root/.vnc/ xstartup
 #sudo echo " " > /root/.vnc/xstartup
 #sudo echo "xrdb $HOME/.Xresources" > /root/.vnc/xstartup
 #sudo echo "startxfce4 &" > /root/.vnc/xstartup
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
 apt-get -f -y install
 #dpkg -i 1c-enterprise83-client-nls_*.deb 
 #apt-get -y install ttf-mscorefonts-installer
 #apt-get -y    install --reinstall ttf-mscorefonts-installer
 
 #apt-get -y install imagemagick-6.q16:i386
 #apt-get -y install imagemagick:i386

 chown -R usr1cv8:grp1cv8 /opt/1C

 systemctl enable srv1cv83
 systemctl stop srv1cv83

 yes | cp -i backbas.so /opt/1C/v8.3/i386
 
 ;;
 
 8) 
 echo "Installing postgres"
 locale -a
 locale-gen ru_RU.UTF-8
 dpkg-reconfigure locales

 sh -c 'echo "deb http://1c.postgrespro.ru/deb/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/postgrespro-1c.list'
 wget --quiet -O - http://1c.postgrespro.ru/keys/RPM-GPG-KEY-POSTGRESPRO-1C-92 | sudo apt-key add - && sudo apt-get update
 apt-get -y install postgresql-pro-1c-9.6

 chown -R postgres:postgres /etc/postgresql/
 chown -R postgres:postgres /var/lib/postgresql/

 sudo systemctl enable postgresql
 sudo systemctl start postgresql
 
 sudo systemctl enable srv1cv83
 sudo systemctl start srv1cv83	
 sudo /opt/1C/v8.3/i386/ras --daemon cluster

 sudo -u postgres psql postgres
 
 #sudo systemctl restart postgresql
 #sudo systemctl restart srv1cv83	
 #sudo /opt/1C/v8.3/i386/ras --daemon cluster 
 
 ;;
 9) 
 echo "Installing LXC "
 apt install lxc lxc-templates wget bridge-utils -y
 lxc-checkconfig
 /etc/init.d/apparmor restart
 ;;
 
 10) 
 echo "Installing vncserver"
 sudo apt -y install vnc4server
 ;; 
 
 11) 
 echo "Configure vncserver"
 sudo apt-get -y install nano mc
 sudo apt -y install vnc4server
 vncserver
 vncserver -kill :1
 sudo echo " " > ~./.vnc/xstartup
 sudo echo "xrdb $HOME/.Xresources" > ~./.vnc/xstartup
 sudo echo "startxfce4 &" > ~./.vnc/xstartup
 ;; 
 
 esac
 done
 
fi
