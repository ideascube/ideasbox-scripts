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

# update package list and install hostapd
echo -n "Update package list and install hostapd: "
sudo apt-get update && sudo apt-get -y install openssh-server
check
