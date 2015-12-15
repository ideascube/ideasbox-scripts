#!/bin/bash
ROOT=/home/ideasbox/Scripts/ka-lite
CURRENT=$PWD
LOG_FILE=install.log

# Clone repository
if [ ! -d "$ROOT" ]
then
	echo "KA Lite installation"
	echo "KA Lite installation" &>> $LOG_FILE
	pip install ka-lite
	kalite start
fi

# Install Nginx vhost
cd $CURRENT
sudo cp 08_kalite/nginx.vhost /etc/nginx/sites-available/kalite
sudo ln -fs /etc/nginx/sites-available/kalite /etc/nginx/sites-enabled/kalite
sudo service nginx restart

