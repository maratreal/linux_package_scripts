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

 esac
 done
fi