#!/bin/bash

if [[ $EUID -ne 0 ]]; then
 echo "This script must be run as root" 
exit 1
else

sudo apt-get install dialog
 cmd=(dialog --separate-output --checklist "Please Select lxc options:" 22 76 16)
 options=(
 1 "HOST Install lxc 1capache" off
 2 "Configure host" off
 3 "Configure LXC" off
 4 "HOST bind directories" off
 )
 choices=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
 clear
 for choice in $choices
 do
 case $choice in
 
1) 
 echo "Creating lxc 1capache"
 apt-get -y install ca-certificates
 lxc-create -t ubuntu -n 1capache -- -r trusty -a i386
 lxc-ls -f
 lxc-start -n 1capache -d
 lxc-info -n 1capache
 lxc-console -n 1capache
 ;;
 
2) 
 echo "Configuring host"
 
 PKG_OK=$(dpkg-query -W --showformat='${Status}\n' apache2-bin|grep "install ok installed")
 echo Checking for somelib: $PKG_OK
 if [ "" == "$PKG_OK" ]; then
   echo "No somelib. Setting up somelib."
   sudo apt-get --force-yes --yes install apache2-bin
 fi
 
 if [ ! -d /1c ]; then
  sudo mkdir /1c
  sudo chmod 777 /1c
 fi
 
 mount --bind /1c /var/lib/lxc/1capache/rootfs/1c
 mount --bind /opt/1C /var/lib/lxc/1capache/rootfs/opt/1C
 
 sudo /opt/1C/v8.3/i386/webinst -apache24 -wsdir eng -dir /1c/eng -connstr "Srvr="$(hostname)";Ref=eng;" -confPath /var/lib/lxc/1capache/rootfs/etc/apache2/apache2.conf
 ;;

3) 
 echo "Configure LXC"
 
 if [ ! -d /1c ]; then
  mkdir /1c
  mkdir /opt/1C
 fi
 
 apt-get -y --force-yes --yes install nano mc
 apt-get -y wget 
 sudo apt-get -y install rpl
 sudo apt-get -y install apache2 apache2-bin apache2-data libapache2-mod-rpaf 
 
 ip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
 new_text="RPAFproxy_ips~"$ip 
 cp -i /etc/apache2/mods-enabled/rpaf.conf rpaf.conf
 rpl "RPAFproxy_ips" $new_text rpaf.conf

 rpl "#   RPAFheader X-Real-IP" "~~~~RPAFheader~X-Forwarded-For" rpaf.conf
 rpl "~" " "  rpaf.conf
 
 cp -i rpaf.conf /etc/apache2/mods-enabled/rpaf.conf
 rm rpaf.conf
 
 check=$(wget -O - -q icanhazip.com)
 sudo echo $check >> /etc/hosts
 ;;

4) 
 echo "HOST bind directories"
 mount --bind /1c /var/lib/lxc/1capache/rootfs/1c
 mount --bind /opt/1C /var/lib/lxc/1capache/rootfs/opt/1C
 
 esac
 done
 
fi
