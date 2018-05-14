#!/bin/bash

if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root" 
exit 1
else

sudo apt-get install dialog
 cmd=(dialog --separate-output --checklist "Please Select lxc options:" 22 76 16)
 options=(
 1 "Install apache2-bin" off
 2 "Configure host"      off
 3 "Install lxc 1capache"        off
 4 "Install apache2 praf mod" off
 5 "Edit rpaf.conf"      off
 )
 choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
 clear
 for choice in $choices
 do
 case $choice in
 
1) 
 echo "Installing apache2-bin"
 apt-get -y install apache2-bin
 ;;
 
2) 
 echo "Configuring host"
 
 sudo mkdir /1c
 sudo chmod 777 /1c
  
 $database = "eng"
 /opt/1C/v8.3/i386/webinst -apache24 -wsdir $database -dir /1c/$database -connstr Srvr=$(hostname)";"Ref=$database; -confPath /var/lib/lxc/1capache/rootfs/etc/apache2/apache2.conf
 
 ;;
 
3) 
 echo "Creating lxc 1capache"
 apt-get -y install ca-certificates
 lxc-create -t ubuntu -n 1capache -- -r trusty -a i386
 lxc-ls -f
 lxc-start -n 1capache -d
 lxc-info -n 1capache
 lxc-console -n 1capache
 
 mkdir /1c
 mkdir /opt/1C
;;


 4) 
 echo "Install apache2 praf mod"
 apt-get install -y apache2 apache2-bin apache2-data libapache2-mod-rpaf
 ;;
 
 5) 
 echo "Editing rpaf.conf"
 
 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' rpl|grep "install ok installed")
 echo Checking for somelib: $PKG_OK
 if [ "" == "$PKG_OK" ]; then
   echo "No somelib. Setting up somelib."
   sudo apt-get --force-yes --yes install rpl
 fi
 
 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' nano mc|grep "install ok installed")
 echo Checking for somelib: $PKG_OK
 if [ "" == "$PKG_OK" ]; then
   echo "No somelib. Setting up somelib."
   sudo apt-get --force-yes --yes install nano mc
 fi
 
 #ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]$
 ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
 new_text="RPAFproxy_ips~"$ip 
 cp -i /etc/apache2/mods-enabled/rpaf.conf rpaf.conf
 rpl "RPAFproxy_ips" $new_text rpaf.conf

 rpl "#   RPAFheader X-Real-IP" "~~~~RPAFheader~X-Forwarded-For" rpaf.conf
 rpl "~" " "  rpaf.conf
 
 cp -i rpaf.conf /etc/apache2/mods-enabled/rpaf.conf
 
 esac
 done
 
fi
