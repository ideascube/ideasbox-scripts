#!/bin/bash

# find all conponent to install
ALL_INSTALL=$(find . -name "install.sh")

# update package list
sudo apt-get update

# launch each install script
for SCRIPT in $ALL_INSTALL; do
	if [[ `dirname $SCRIPT` != '.' ]]; then
		if [[ -x $SCRIPT ]]; then
			sudo $SCRIPT
		else
			echo "$SCRIPT is not executable"
		fi
	fi
done

# Update serveur
sudo apt-get upgrade
