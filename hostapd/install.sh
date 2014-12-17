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
	echo -n "Adding hostapd repository: "
	sudo add-apt-repository -y ppa:andykimpe/hostapd >> $LOG_FILE 2>> $LOG_FILE
	check

	# update package list and install hostapd
	echo -n "Update package list and install hostapd: "
	sudo apt-get update >> $LOG_FILE 2>> $LOG_FILE && \
	sudo apt-get -y install hostapd >> $LOG_FILE 2>> $LOG_FILE
	check

fi

# backup default configuration
if [[ -e "$CONFIG_DIR/hostapd.conf" ]]; then
	echo -n "Back-up default hostapd configuration: "
	sudo cp $CONFIG_DIR/hostapd.conf $CONFIG_DIR/hostapd.conf.back >> $LOG_FILE 2>> $LOG_FILE
	check
fi

# put our hostapd.conf file
echo -n "Copying config file: "
sudo cp $CONF_PATH/hostapd.conf $CONFIG_DIR >> $LOG_FILE 2>> $LOG_FILE
check

# check if hostapd daemon exist
if [[ -e "/etc/init.d/hostapd" ]]; then
	# set default conf file in hostapd service file
	echo -n "Update hostapd service file: "
	sudo sed -ri s:^DAEMON_CONF=$:DAEMON_CONF=/etc/hostapd/hostapd.conf: /etc/init.d/hostapd >> $LOG_FILE 2>> $LOG_FILE
	check
else
	echo -n "Copy hostapd daemon in /etc/init.d: "
	sudo cp $CONFIG_DIR/hostapd /etc/init.d >> $LOG_FILE 2>> $LOG_FILE
	check
fi
