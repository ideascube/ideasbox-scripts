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
echo -n "Copying config file: "
sudo mv ./hostapd.conf $CONFIG_DIR
check

# set default conf file in hostapd service file
echo -n "Update hostapd service file: "
sudo sed -ri s:^DAEMON_CONF=$:DAEMON_CONF=/etc/hostapd/hostapd.conf: /etc/init.d/hostapd
check
