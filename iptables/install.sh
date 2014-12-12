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
echo -n "Install iptables: "
sudo apt-get -y install iptables >> $LOG_FILE 2>> $LOG_FILE
check

# authorise NAT
echo -n "Authorize NAT: "
sudo sed -ri s:^#net.ipv4.ip_forward=1$:net.ipv4.ip_forward=1: /etc/sysctl.conf >> $LOG_FILE 2>> $LOG_FILE
check

# reload sysctl conf
echo -n "Reload sysctl conf: "
sudo sysctl -p
check

# create iptables rules
echo -n "Create iptables rules: "
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE  >> $LOG_FILE 2>> $LOG_FILE && \
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT >> $LOG_FILE 2>> $LOG_FILE && \
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT >> $LOG_FILE 2>> $LOG_FILE
check

# save iptables to file which will load after start
echo -n "Save iptables rules: "
sudo iptables-save > /etc/iptables.nat >> $LOG_FILE 2>> $LOG_FILE
check

# create a file with forwarding in /etc/network/if-up.d
echo -n "Create a file with forwarding: "
sudo cat > /etc/network/if-up.d/forwarding << EoF
#!/bin/sh
iptables-restore
EoF
check

# chmod +x previous file
echo -n "Give execution right to previously created script: "
sudo chmod +x /etc/network/if-up.d/forwarding >> $LOG_FILE 2>> $LOG_FILE
check
