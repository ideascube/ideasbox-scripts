#!/bin/bash

check() {
	# check last command status
	if [[ "$?" -eq 0 ]]; then
		echo -e "\033[32mOK\033[0m"
	else
		echo -e "\033[31mKO\033[0m"
		if [[ "$1" == "wait" ]]; then
			read -p "Press any key to pass to quit"
		fi
		exit 1
	fi
}
