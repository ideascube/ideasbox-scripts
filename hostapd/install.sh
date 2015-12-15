#!/bin/bash
# IdeasCube Script
#
# hostapd installation 
#
# 1. install or upgrade the package hostapd
# 2. backup default configuration
# 3. copy our hostapd configuration
# 4. check if hostapd daemon exist, if yes, we change the DAEMON_CONF location, if not, we install it
#
#####

NOW=$(date +%Y%m%d%H%M)

if [[ -z "$1" ]]; then
	LOG_FILE="install.log"
else
	LOG_FILE="$1"
fi

ls res > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]; then
	source res/check.sh
	CONF_PATH="hostapd"
else
	source ../res/check.sh
	CONF_PATH="."
fi

CONFIG_DIR="/etc/hostapd"

# install hostapd
if [[ -z "$VERBOSE" ]]; then
	echo -n "Install hostapd: "
	sudo apt-get -y install hostapd &>> $LOG_FILE
	check
else
	sudo apt-get -y install hostapd 2>&1 | tee -a $LOG_FILE
	echo "Install hostapd: `check`"
fi

# backup default configuration
if [[ -e "$CONFIG_DIR/hostapd.conf" ]]; then
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Back-up default hostapd configuration: "
		sudo cp $CONFIG_DIR/hostapd.conf $CONFIG_DIR/hostapd.conf.back-$NOW &>> $LOG_FILE
		check
	else
		sudo cp $CONFIG_DIR/hostapd.conf $CONFIG_DIR/hostapd.conf.back-$NOW 2>&1 | tee -a $LOG_FILE
		echo "Back-up default hostapd configuration: `check`"
	fi
fi

# put our hostapd.conf file
if [[ -z "$VERBOSE" ]]; then
	echo -n "Copying config file: "
	sudo cp $CONF_PATH/hostapd.conf $CONFIG_DIR &>> $LOG_FILE
	check
else
	sudo cp $CONF_PATH/hostapd.conf $CONFIG_DIR 2>&1 | tee -a $LOG_FILE
	echo "Copying config file: `check`"
fi

# check if hostapd daemon exist
if [[ -e "/etc/init.d/hostapd" ]]; then
	# set default conf file in hostapd service file
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Update hostapd service file: "
		sudo sed -ri s:^DAEMON_CONF=$:DAEMON_CONF=/etc/hostapd/hostapd.conf: /etc/init.d/hostapd &>> $LOG_FILE
		check
	else
		sudo sed -ri s:^DAEMON_CONF=$:DAEMON_CONF=/etc/hostapd/hostapd.conf: /etc/init.d/hostapd 2>&1 | tee -a $LOG_FILE
		echo "Update hostapd service file: `check`"
	fi
else
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Copy hostapd daemon in /etc/init.d: "
		sudo cp $CONF_PATH/hostapd /etc/init.d &>> $LOG_FILE
		check
	else
		sudo cp $CONF_PATH/hostapd /etc/init.d 2>&1 | tee -a $LOG_FILE
		echo "Copy hostapd daemon in /etc/init.d: `check`"
	fi
fi

# add hostapd as service
if [[ -z "$VERBOSE" ]]; then
	echo -n "Add hostapd to services: "
	sudo update-rc.d hostapd defaults &>> $LOG_FILE
	check
else
	sudo update-rc.d hostapd defaults 2>&1 | tee -a $LOG_FILE
	echo -n "Add hostapd to services: `check`"
fi
