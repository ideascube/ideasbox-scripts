#!/bin/bash

LOG_FILE="install.log"
source res/check.sh

# install python
if [[ -z "$VERBOSE" ]]; then
	echo -n "Install python: "
	sudo apt-get -y install python python-pip python-setuptools &>> $LOG_FILE
	check
else
	sudo apt-get -y install python python-pip python-setuptools 2>&1 | tee -a $LOG_FILE
	echo "Install python: `check`"
fi
