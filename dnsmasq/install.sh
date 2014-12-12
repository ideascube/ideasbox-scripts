#!/bin/bash

if [[ -z "$1" ]]; then
	LOG_FILE="install.log"
else
	LOG_FILE="$1"
fi

CONFIG_DIR="/etc"

# update package list and install dnsmaq
echo -n "Install dnsmaq: "
sudo apt-get install dnsmasq >> $LOG_FILE 2>> $LOG_FILE
check

# backup default configuration
echo -n "Back-up default dnsmaq configuration: "
sudo mv $CONFIG_DIR/dnsmasq.conf $CONFIG_DIR/dnsmasq.conf.back >> $LOG_FILE 2>> $LOG_FILE
check

# put our dnsmaq.conf file
echo -n "Copying config file"
sudo mv ./dnsmasq.conf $CONFIG_DIR >> $LOG_FILE 2>> $LOG_FILE
check
