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

# check if root
if [ `id -u` != '0' ]; then
	echo "You need to be root to execute this script."
	exit 0
fi

CONFIG_DIR="/etc"

# update package list and install dnsmaq
echo -n "Update package list and install dnsmaq: "
sudo apt-get update && sudo apt-get install dnsmasq
check

# backup default configuration
echo -n "Back-up default dnsmaq configuration: "
sudo mv $CONFIG_DIR/dnsmasq.conf $CONFIG_DIR/dnsmasq.conf.back
check

# put our dnsmaq.conf file
echo -n "Copying config file"
sudo mv ./dnsmasq.cong $CONFIG_DIR
check
