#!/bin/bash

# check if root
if [ `id -u` != '0' ]; then
	echo "You need to be root to execute this script."
	exit 0
fi

# find all conponent to install
ALL_INSTALL=$(find . -name "install.sh")

# launch each install script
for SCRIPT in $ALL_INSTALL; do
	if [[ `dirname $SCRIPT` != '.' ]]; then
		if [[ -x $SCRIPT ]]; then
			$SCRIPT
		else
			echo "$SCRIPT is not executable"
		fi
	fi
done
