#!/bin/bash

usage() {
	echo "Usage: ./install.sh [options]"
	echo "Availables options :"
	echo "	-h --help		: display this help"
	echo "	-v --verbose	: the script will be verbose"
}

get_param() {
	while test $# -gt 0; do
		case "$1" in
			-h|--help)
				usage
				exit 0
				;;
			-v|--verbose)
				VERBOSE=YES
				;;
			*)
				break
				;;
		esac
		shift
	done
}

update_package_list() {
	# update package list
	if [[ -z "$VERBOSE" ]];then
		echo -n "Update package list: "
		sudo apt-get update &>> install.log
		check wait
	else
		sudo apt-get update 2>&1 | tee -a install.log
		echo "Update package list: `check`"
	fi
}

update_package() {
	# update serveur
	if [[ -z "$VERBOSE" ]]; then
		echo -n "Update package: "
		sudo apt-get upgrade -y &>> install.log
		check wait
	else
		sudo apt-get upgrade -y 2>&1 | tee -a install.log
		echo "Update package: `check`"
	fi
}

install_needed_packages() {
	# find all conponent to install
	ALL_INSTALL=$(find . -mindepth 2 -name "install.sh")
	# launch each install script
	for SCRIPT in $ALL_INSTALL; do
		if [[ -x $SCRIPT ]]; then
			sudo $SCRIPT "install.log"
		else
			echo "$SCRIPT is not executable"
		fi
	done
}

init_install() {
	if [[ -z "$FIRST_TIME" ]]; then
		if [[ -e install.log ]]; then
			mv install.log install.log.old
		fi
		source res/check.sh
		sudo ls &> /dev/null
		update_package_list
		FIRST_TIME=NOPE
	fi
}

select_packages_to_install() {
	PREV="Back to previous menu"
	PS3="Please enter your choice: "
	# find package list
	packages=( `find . -mindepth 2 -name "install.sh" | sed -r "s:\./([a-zA-Z0-9\-]+)/install.sh:\1:"` )
	while [[ -z "$STOP" ]]; do
		select opt in "${packages[@]}" "$PREV"; do
			if [[ -n "$opt" ]]; then
				if [[ "$opt" = $PREV ]]; then
					echo "$PREV"
					STOP="Yep"
				else
					init_install
					./$opt/install.sh
				fi
			else
				echo "Invalid choice"
			fi
			break
		done
	done
	unset STOP
}

update_hostname() {
	while [[ -z "$hostname" ]]; do
		echo "You can change the hostname when prompt or keep the current one by typyng 'Enter'"
		echo "If you change the hostname, make it as explicit as possible"
		echo "The current hostname is: `hostname`"
		echo -n "Please, enter the hostname: "
		read hostname
		if [[ "${#hostname}" -eq 0 ]]; then
			hostname="nope"
		elif [[ "${#hostname}" -lt 4 ]]; then
			echo "Hostname too short"
			unset hostname
		else
			sudo sed -i "s/.*/$hostname/" /etc/hostname
			sudo sed -ir "s/(127.0.1.1\s+)[a-zA-Z0-9_-]+/\1$hostname/" /etc/hosts
			sudo hostname $hostname
		fi
	done
	unset hostname
}

main_menu() {
	PS3="Please enter your choice: "
	options=("Full install" "Update packages" "Install all needed package" "Select which package to install" "Change hostname")
	while [[ -z "$STOP" ]]; do
		select opt in "${options[@]}" "Quit"; do
			case $opt in
				"Full install")
					update_hostname
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
					select_packages_to_install
					;;
				"Change hostname")
					update_hostname
					;;
				"Quit")
					unset FIRST_TIME
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
	unset STOP
}

main() {
	get_param "$@"
	echo -e "Welcome to the IdeasCube installer.\n"
	main_menu
}

main "$@"
