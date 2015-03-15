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
if [[ -z "$VERBOSE" ]]; then
	echo -n "Install open-ssh: "
	sudo apt-get -y install openssh-server &>> $LOG_FILE
	check
else
	sudo apt-get -y install openssh-server 2>&1 | tee -a $LOG_FILE
	echo "Install open-ssh: `check`"
fi
