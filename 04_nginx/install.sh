#!/bin/bash

LOG_FILE="install.log"
source res/check.sh

# install nginx
if [[ -z "$VERBOSE" ]]; then
        echo -n "Install nginx: "
        if ps ax | grep -v grep | grep apache > /dev/null; then
			APACHE="running"
			sudo service apache2 stop
		fi
        sudo apt-get -y install nginx &>> $LOG_FILE
        check
        if [[ ! -z $APACHE ]]; then
        	sudo service apache2 stop
    	fi
else
        sudo apt-get -y install nginx 2>&1 | tee -a $LOG_FILE
        echo "Install nginx: `check`"
fi

# Some config
sudo sed -ie "s/server_name.*/server_name $(hostname)/g" /etc/nginx/nginx.conf
sudo sed -ie "s/client_max_body_size.*/client_max_body_size 200M/g" /etc/nginx/nginx.conf
