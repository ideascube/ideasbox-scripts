#!/bin/bash

if [[ -z "$1" ]]; then
	LOG_FILE="install.log"
else
	LOG_FILE="$1"
fi

# update package list and install hostapd
echo -n "Install hostapd: "
sudo apt-get -y install openssh-server >> $LOG_FILE 2>> $LOG_FILE
check
