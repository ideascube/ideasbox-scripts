#!/bin/bash

update_package_list() {
	# update package list
	echo -n "Update package list: "
	sudo apt-get update >> install.log 2>> install.log
	check wait
}

update_package() {
	# update serveur
	echo -n "Update package: "
	sudo apt-get upgrade >> install.log 2>> install.log << EoC
Y
EoC
	check wait
}

install_needed_packages() {
	# find all conponent to install
	ALL_INSTALL=$(find . -name "install.sh")
	# launch each install script
	for SCRIPT in $ALL_INSTALL; do
		if [[ `dirname $SCRIPT` != '.' ]]; then
			if [[ -x $SCRIPT ]]; then
				sudo $SCRIPT "install.log"
			else
				echo "$SCRIPT is not executable"
			fi
		fi
	done
}

init_install() {
	if [[ -z "$FIRST_TIME" ]]; then
		if [[ -f install.log ]]; then
			mv install.log install.log.old
		fi
		source res/check.sh
		sudo ls > /dev/null 2> /dev/null
		update_package_list
		FIRST_TIME=NOPE
	fi
}

main_menu() {
	PS3="Please enter your choice: "
	options=("Full install" "Update packages" "Install all needed package" "Select which package to install")
	while [[ -z "$STOP" ]];
	do
		select opt in "${options[@]}" "Quit"
		do
			case $opt in
				"Full install")
					init_install
					update_package
					install_needed_packages
					;;
				"Update packages")
					init_install
					update_package
					;;
				"Install all needed package")
					init_install
					install_needed_packages
					;;
				"Select which package to install")
					init_install
					;;
				"Quit")
					unset $FIRST_TIME
					STOP="Yep"
					;;
				*)
					echo "Invalid option"
					;;
			esac
			break
		done
		echo " "
	done
	unset $STOP
}

main() {
	echo "Welcome in the IdeasBox installer.\n"
	main_menu
}

main
