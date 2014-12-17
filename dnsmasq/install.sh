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
if [[ -z "$VERBOSE" ]]; then
	echo -n "Install dnsmaq: "
	sudo apt-get install dnsmasq &>> $LOG_FILE
	check
else
	sudo apt-get install dnsmasq 2>&1 | tee -a $LOG_FILE
	echo "Install dnsmaq: `check`"
fi

# backup default configuration
if [[ -e "$CONFIG_DIR/dnsmasq.conf" ]]; then
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Back-up default dnsmaq configuration: "
		sudo cp $CONFIG_DIR/dnsmasq.conf $CONFIG_DIR/dnsmasq.conf.back &>> $LOG_FILE
		check
	else
		sudo cp $CONFIG_DIR/dnsmasq.conf $CONFIG_DIR/dnsmasq.conf.back 2>&1 | tee -a $LOG_FILE
		echo "Back-up default dnsmaq configuration: `check`"
	fi
fi

# put our dnsmaq.conf file
if [[ -z "$VERBOSE" ]]; then
	echo -n "Copying config file: "
	sudo cp $CONF_PATH/dnsmasq.conf $CONFIG_DIR &>> $LOG_FILE
	check
else
	sudo cp $CONF_PATH/dnsmasq.conf $CONFIG_DIR 2>&1 | tee -a $LOG_FILE
	echo "Copying config file: `check`"
fi

# backup current network configuration
if [[ -e "/etv/network/interfaces" ]]; then
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Backup current network configuration: "
		sudo cp /etc/network/interfaces /etc/network/interfaces.back &>> $LOG_FILE
		check
	else
		sudo cp /etc/network/interfaces /etc/network/interfaces.back 2>&1 | tee -a $LOG_FILE
		echo "Backup current network configuration: `check`"
	fi
fi

# put our interfaces file
if [[ -z "$VERBOSE" ]]; then
	echo -n "Configuring network: "
	sudo cp $CONF_PATH/interfaces /etc/network &>> $LOG_FILE
	check
else
	sudo cp $CONF_PATH/interfaces /etc/network 2>&1 | tee -a $LOG_FILE
	echo "Configuring network: `check`"
fi
