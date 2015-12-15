#!/bin/bash
URL=https://github.com/learningequality/ka-lite
ROOT=/home/ideasbox/Scripts/ka-lite
CURRENT=$PWD
LOG_FILE=install.log

# Clone repository
if [ ! -d "$ROOT" ]
then
	echo "KA Lite installation"
	echo "KA Lite installation" &>> $LOG_FILE
	if [ -z "$VERBOSE" ]; then
    	echo "Cloning $URL"
	fi
	echo "Cloning $URL" &>> $LOG_FILE
    git clone --recursive $URL $ROOT &>> $LOG_FILE
fi

cd $ROOT
./setup_unix.sh

# Install Nginx vhost
cd $CURRENT
sudo cp kalite/nginx.vhost /etc/nginx/sites-available/kalite
sudo ln -fs /etc/nginx/sites-available/kalite /etc/nginx/sites-enabled/kalite
sudo service nginx restart

