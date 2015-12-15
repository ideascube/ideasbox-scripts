#!/bin/bash

NOW=$(date +%Y%m%d%H%M)
if [[ -z "$1" ]]; then
	LOG_FILE="install.log"
else
	LOG_FILE="$1"
fi

ls res &> /dev/null
if [[ $? -eq 0 ]]; then
	source res/check.sh
	CONF_PATH="06_dnsmasq"
else
	source ../res/check.sh
	CONF_PATH="."
fi

CONFIG_DIR="/etc"
NETWORK_DIR="/etc/network"

# update package list and install dnsmaq
if [[ -z "$VERBOSE" ]]; then
	echo -n "Install dnsmaq: "
	sudo apt-get install -y dnsmasq &>> $LOG_FILE
	check
else
	sudo apt-get install -y dnsmasq 2>&1 | tee -a $LOG_FILE
	echo "Install dnsmaq: `check`"
fi

# backup default configuration
if [[ -e "$CONFIG_DIR/dnsmasq.conf" ]]; then
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Back-up default dnsmaq configuration: "
		sudo cp $CONFIG_DIR/dnsmasq.conf $CONFIG_DIR/dnsmasq.conf.back-$NOW &>> $LOG_FILE
		check
	else
		sudo cp $CONFIG_DIR/dnsmasq.conf $CONFIG_DIR/dnsmasq.conf.back-$NOW 2>&1 | tee -a $LOG_FILE
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
if [[ -e "$NETWORK_DIR/interfaces" ]]; then
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Backup current network configuration: "
		sudo cp $NETWORK_DIR/interfaces $NETWORK_DIR/interfaces.back-$NOW &>> $LOG_FILE
		check
	else
		sudo cp $NETWORK_DIR/interfaces $NETWORK_DIR/interfaces.back-$NOW 2>&1 | tee -a $LOG_FILE
		echo "Backup current network configuration: `check`"
	fi
fi

# put our interfaces file
if [[ -z "$VERBOSE" ]]; then
	echo -n "Configuring network: "
	sudo cp $CONF_PATH/interfaces $NETWORK_DIR &>> $LOG_FILE
	check
else
	sudo cp $CONF_PATH/interfaces $NETWORK_DIR 2>&1 | tee -a $LOG_FILE
	echo "Configuring network: `check`"
fi

# http://seravo.fi/2014/create-wireless-access-point-hostapd
LINE="iptables -t nat -A POSTROUTING -s 192.168.2.0/24 ! -d 192.168.2.0/24  -j MASQUERADE"
FILE="/etc/rc.local"
MATCH="exit 0"
if ! grep -qF "$LINE" $FILE
then
    # Insert iptables before last line
    sed -i "s/$MATCH/$LINE\n$MATCH/" $FILE
fi
