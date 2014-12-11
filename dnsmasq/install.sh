#!/bin/bash

check() {
	if [[ "$?" -eq 0 ]]; then
		echo -e "\033[32mOK\033[0m"
	else
		echo -e "\033[31mKO\033[0m"
		read -p "Press any key to pass this install"
		exit 1
	fi
}

CONFIG_DIR="/etc"

# update package list and install dnsmaq
echo -n "Install dnsmaq: "
sudo apt-get install dnsmasq
check

# backup default configuration
echo -n "Back-up default dnsmaq configuration: "
sudo mv $CONFIG_DIR/dnsmasq.conf $CONFIG_DIR/dnsmasq.conf.back
check

# put our dnsmaq.conf file
echo -n "Copying config file"
sudo mv ./dnsmasq.conf $CONFIG_DIR
check
