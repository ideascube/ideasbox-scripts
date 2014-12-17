#!/bin/bash

if [[ -z "$1" ]]; then
	LOG_FILE="install.log"
else
	LOG_FILE="$1"
fi

ls res &> /dev/null
if [[ $? -eq 0 ]]; then
	source res/check.sh
	CONF_PATH="dnsmasq"
else
	source ../res/check.sh
	CONF_PATH="."
fi

CONFIG_DIR="/etc"

# update package list and install dnsmaq
echo -n "Install dnsmaq: "
sudo apt-get install dnsmasq &>> $LOG_FILE
check

# backup default configuration
if [[ -e "$CONFIG_DIR/dnsmasq.conf" ]]; then
	echo -n "Back-up default dnsmaq configuration: "
	sudo cp $CONFIG_DIR/dnsmasq.conf $CONFIG_DIR/dnsmasq.conf.back &>> $LOG_FILE
	check
fi

# put our dnsmaq.conf file
echo -n "Copying config file"
sudo cp $CONF_PATH/dnsmasq.conf $CONFIG_DIR &>> $LOG_FILE
check

# backup current network configuration
if [[ -e "/etv/network/interfaces" ]]; then
	echo -n "Backup current network configuration: "
	sudo cp /etc/network/interfaces /etc/network/interfaces.back &>> $LOG_FILE
	check
fi

# put our interfaces file
echo -n "Configuring network: "
sudo cp $CONF_PATH/interfaces /etc/network &>> $LOG_FILE
check
