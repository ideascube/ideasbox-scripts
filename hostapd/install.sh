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

CONFIG_DIR="/etc/hostapd"

# add hostapd repository
echo -n "Adding hostapd repository: "
sudo add-apt-repository -y ppa:andykimpe/hostapd
check

# update package list and install hostapd
echo -n "Update package list and install hostapd: "
sudo apt-get update && sudo apt-get -y install hostapd
check

# backup default configuration
echo -n "Back-up default hostapd configuration: "
sudo mv $CONFIG_DIR/hostapd.conf $CONFIG_DIR/hostapd.conf.back
check

# put our hostapd.conf file
echo -n "Copying config file"
sudo mv ./hostapd.cong $CONFIG_DIR
check
