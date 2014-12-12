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

CONFIG_DIR="/etc/hostapd"

# add hostapd repository
echo -n "Adding hostapd repository: "
sudo add-apt-repository -y ppa:andykimpe/hostapd >> $LOG_FILE 2>> $LOG_FILE
check

# update package list and install hostapd
echo -n "Update package list and install hostapd: "
sudo apt-get update >> $LOG_FILE 2>> $LOG_FILE && \
sudo apt-get -y install hostapd >> $LOG_FILE 2>> $LOG_FILE
check

# backup default configuration
echo -n "Back-up default hostapd configuration: "
sudo mv $CONFIG_DIR/hostapd.conf $CONFIG_DIR/hostapd.conf.back >> $LOG_FILE 2>> $LOG_FILE
check

# put our hostapd.conf file
echo -n "Copying config file: "
sudo mv ./hostapd.conf $CONFIG_DIR >> $LOG_FILE 2>> $LOG_FILE
check

# set default conf file in hostapd service file
echo -n "Update hostapd service file: "
sudo sed -ri s:^DAEMON_CONF=$:DAEMON_CONF=/etc/hostapd/hostapd.conf: /etc/init.d/hostapd >> $LOG_FILE 2>> $LOG_FILE
check
