#!/bin/bash

LOG_FILE="install.log"
source res/check.sh

# install nginx
if [[ -z "$VERBOSE" ]]; then
	echo -n "Install nginx: "
	sudo apt-get -y install nginx &>> $LOG_FILE
	check
else
	sudo apt-get -y install nginx 2>&1 | tee -a $LOG_FILE
	echo "Install nginx: `check`"
fi
