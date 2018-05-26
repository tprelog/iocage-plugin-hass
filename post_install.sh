#!/bin/bash 
File="$0"
Folder=`pwd`

install_menu () {

  case $@ in
    
    hass)
      install_hass
    ;;
      
    10) # Exit Script
      echo "Goodbye!"
      exit 0
    ;;
      
    *) # print stop $1 -- stop "BLAH BLAH" will print "BLAH BLAH" to screen
      printf " \033[31m %s \n\033[0m" "$1"
      echo "Invalid!: "$1""
      exit
      ;;

  esac

}

install_hass () {

  echo " Installing homeassistant virtualenv for: `whoami`"
  sleep 2 # sleep 2 so we check we're the right person above
  virtualenv -p /usr/local/bin/python3.6 /srv/homeassistant
  source /srv/homeassistant/bin/activate
  pip3 install --upgrade homeassistant
  exit
  
}

install_base () {

  sed -i .bak "s/^umask.*/umask 2/g" /root/.cshrc

  install -d -g 990 -o 990 -m 775 -- /home/hass
  pw addgroup -g 990 -n hass
  pw adduser -u 990 -n hass -d /home/hass -s /usr/local/bin/bash -G dialer -c "Daemon user for Homeassistant"

  python3.6 -m ensurepip
  pip3 install --upgrade pip
  pip3 install --upgrade virtualenv

  install -d -g hass -o hass -m 775 -- /srv/homeassistant
  install -d /usr/local/etc/rc.d

  screen -dmS hass su - hass -c "bash ${Folder}/${File} hass"
  screen -r hass

#  cp daemon.homeassistant /usr/local/etc/rc.d/homeassistant
  chmod +x /usr/local/etc/rc.d/homeassistant
  sysrc -f /etc/rc.conf homeassistant_enable=yes
  service homeassistant start 2>/dev/null
  echo "Finished!"

}

if [ -z "$1" ]; then
  install_base
else
  install_menu "$1"
fi
