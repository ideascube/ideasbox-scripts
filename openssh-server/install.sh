#!/bin/bash

if [[ -z "$1" ]]; then
	LOG_FILE="install.log"
else
	LOG_FILE="$1"
fi

ls res > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]; then
	source res/check.sh
else
	source ../res/check.sh
fi

# update package list and install hostapd
echo -n "Install hostapd: "
sudo apt-get -y install openssh-server &>> $LOG_FILE
check
