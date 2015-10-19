#!/bin/bash

LOG_FILE="install.log"
source res/check.sh

# install git
if [[ -z "$VERBOSE" ]]; then
	echo -n "Install git: "
	sudo apt-get -y install git &>> $LOG_FILE
	check
else
	sudo apt-get -y install git 2>&1 | tee -a $LOG_FILE
	echo "Install git: `check`"
fi
