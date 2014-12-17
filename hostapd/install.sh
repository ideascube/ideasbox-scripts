#!/bin/bash

if [[ -z "$1" ]]; then
	LOG_FILE="install.log"
else
	LOG_FILE="$1"
fi

ls res > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]; then
	source res/check.sh
	CONF_PATH="hostapd"
else
	source ../res/check.sh
	CONF_PATH="."
fi

CONFIG_DIR="/etc/hostapd"

# check if hostapd repository already add
if [[ -z `cd /etc/apt && grep -ir hostapd 2> /dev/null` ]]; then

	# add hostapd repository
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Adding hostapd repository: "
		sudo add-apt-repository -y ppa:andykimpe/hostapd &>> $LOG_FILE
		check
	else
		sudo add-apt-repository -y ppa:andykimpe/hostapd 2>&1 | tee -a $LOG_FILE
		echo "Adding hostapd repository: `check`"
	fi

	# update package list and install hostapd
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Update package list and install hostapd: "
		sudo apt-get update &>> $LOG_FILE && \
		sudo apt-get -y install hostapd &>> $LOG_FILE
		check
	else
		sudo apt-get update 2>&1 | tee -a $LOG_FILE && \
		sudo apt-get -y install hostapd 2>&1 | tee -a $LOG_FILE
		echo "Update package list and install hostapd: `check`"
	fi

fi

# backup default configuration
if [[ -e "$CONFIG_DIR/hostapd.conf" ]]; then
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Back-up default hostapd configuration: "
		sudo cp $CONFIG_DIR/hostapd.conf $CONFIG_DIR/hostapd.conf.back &>> $LOG_FILE
		check
	else
		sudo cp $CONFIG_DIR/hostapd.conf $CONFIG_DIR/hostapd.conf.back 2>&1 | tee -a $LOG_FILE
		echo "Back-up default hostapd configuration: `check`"
	fi
fi

# put our hostapd.conf file
if [[ -z "$VERBOSE" ]]; then
	echo -n "Copying config file: "
	sudo cp $CONF_PATH/hostapd.conf $CONFIG_DIR &>> $LOG_FILE
	check
else
	sudo cp $CONF_PATH/hostapd.conf $CONFIG_DIR 2>&1 | tee -a $LOG_FILE
	echo "Copying config file: `check`"
fi

# check if hostapd daemon exist
if [[ -e "/etc/init.d/hostapd" ]]; then
	# set default conf file in hostapd service file
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Update hostapd service file: "
		sudo sed -ri s:^DAEMON_CONF=$:DAEMON_CONF=/etc/hostapd/hostapd.conf: /etc/init.d/hostapd &>> $LOG_FILE
		check
	else
		sudo sed -ri s:^DAEMON_CONF=$:DAEMON_CONF=/etc/hostapd/hostapd.conf: /etc/init.d/hostapd 2>&1 | tee -a $LOG_FILE
		echo "Update hostapd service file: `check`"
	fi
else
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Copy hostapd daemon in /etc/init.d: "
		sudo cp $CONF_PATH/hostapd /etc/init.d &>> $LOG_FILE
		check
	else
		sudo cp $CONF_PATH/hostapd /etc/init.d 2>&1 | tee -a $LOG_FILE
		echo "Copy hostapd daemon in /etc/init.d: `check`"
	fi
fi
