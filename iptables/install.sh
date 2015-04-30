#!/bin/bash

if [[ -z "$1" ]]; then
	LOG_FILE="install.log"
else
	LOG_FILE="$1"
fi

ls res > /dev/null 2> /dev/null
if [[ $? -eq 0 ]]; then
	source res/check.sh
else
	source ../res/check.sh
fi

# install iptables
if [[ -z "$VERBOSE" ]]; then
	echo -n "Install iptables: "
	sudo apt-get -y install iptables &>> $LOG_FILE
	check
else
	sudo apt-get -y install iptables 2>&1 | tee -a $LOG_FILE
	echo -n "Install iptables: `check`"
fi

# authorise NAT
if [[ -z "$VERBOSE" ]]; then
	echo -n "Authorize NAT: "
	sudo sed -ri s:^#net.ipv4.ip_forward=1$:net.ipv4.ip_forward=1: /etc/sysctl.conf &>> $LOG_FILE
	check
else
	sudo sed -ri s:^#net.ipv4.ip_forward=1$:net.ipv4.ip_forward=1: /etc/sysctl.conf 2>&1 | tee -a $LOG_FILE
	echo -n "Authorize NAT: `check`"
fi

# reload sysctl conf
if [[ -z "$VERBOSE" ]]; then
	echo -n "Reload sysctl conf: "
	sudo sysctl -p &>> $LOG_FILE
	check
else
	sudo sysctl -p 2>&1 | tee -a $LOG_FILE
	echo -n "Reload sysctl conf: `check`"
fi

# create iptables rules
if [[ -z "$VERBOSE" ]]; then
	echo -n "Create iptables rules: "
	sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  &>> $LOG_FILE && \
	sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT &>> $LOG_FILE && \
	sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT &>> $LOG_FILE
	check
else
	sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 2>&1 | tee -a $LOG_FILE && \
	sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT 2>&1 | tee -a $LOG_FILE && \
	sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT 2>&1 | tee -a $LOG_FILE
	echo -n "Create iptables rules:	`check`"
fi

# save iptables to file which will load after start
echo -n "Save iptables rules: "
sudo iptables-save > /tmp/iptables.nat 2> $LOG_FILE
check

# move iptable file to /etc
if [[ -z "$VERBOSE" ]]; then
	echo -n "Move iptables file to /etc: "
	sudo mv /tmp/iptables.nat /etc &>> $LOG_FILE
	check
else
	sudo mv /tmp/iptables.nat /etc 2>&1 | tee -a $LOG_FILE
	echo -n "Move iptables file to /etc: `check`"
fi

# create a file with forwarding in /etc/network/if-up.d
echo -n "Create a file with forwarding: "
sudo cat > /tmp/forwarding << EoF
#!/bin/sh
iptables-restore /etc/iptables.nat
EoF
check

# move forwarding file to /etc
if [[ -z "$VERBOSE" ]]; then
	echo -n "Move forwarding file to /etc: "
	sudo mv /tmp/forwarding /etc/network/if-up.d/forwarding &>> $LOG_FILE
	check
else
	sudo mv /tmp/forwarding /etc/network/if-up.d/forwarding 2>&1 | tee -a $LOG_FILE
	echo -n "Move forwarding file to /etc: `check`"
fi

# chmod +x previous file
if [[ -z "$VERBOSE" ]]; then
	echo -n "Give execution right to previously created script: "
	sudo chmod +x /etc/network/if-up.d/forwarding &>> $LOG_FILE
	check
else
	sudo chmod +x /etc/network/if-up.d/forwarding 2>&1 | tee -a $LOG_FILE
	echo "Give execution right to previously created script: `check`"
fi
