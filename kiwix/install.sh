#!/bin/bash
#
# Installation of Kiwix daemon (http://download.kiwix.org)
# 
# Install the daemon in /usr/local/bin/kiwix-serve
# Don't install the datas that you should download on Kiwix website
####
URL=http://download.kiwix.org/bin/kiwix-linux-x86_64.tar.bz2
ARCHIVE=kiwix-0.9-linux-x86_64.tar.bz2
BIN=kiwix-serve
FROM_BIN="kiwix/bin/$BIN"
TO_BIN="/usr/local/bin/$BIN"
LOG_FILE=install.log

. res/check.sh

mkdir -p tmp
cd tmp
if [ ! -f "$ARCHIVE" ]
then
    echo "Downloading $URL"
    wget $URL -O $ARCHIVE &>> $LOG_FILE
fi
tar xjvf $ARCHIVE &>> $LOG_FILE
sudo cp $FROM_BIN $TO_BIN &>> $LOG_FILE

# Create data dir
sudo mkdir -p /usr/local/share/kiwix/ &>> $LOG_FILE

# Install service script
cd ..
sudo cp kiwix/kiwix.init /etc/init.d/kiwix &>> $LOG_FILE

# add kiwix as service
if [ -z "$VERBOSE" ]; then
        echo -n "Add kiwix to services: "
        sudo update-rc.d kiwix defaults &>> $LOG_FILE
        check
else
        sudo update-rc.d kiwix defaults 2>&1 | tee -a $LOG_FILE
        echo -n "Add kiwix to services: `check`"
fi

# Install Nginx vhost
sudo cp kiwix/nginx.vhost /etc/nginx/sites-available/kiwix &>> $LOG_FILE
sudo ln -fs /etc/nginx/sites-available/kiwix /etc/nginx/sites-enabled/kiwix &>> $LOG_FILE
sudo service nginx restart &>> $LOG_FILE


