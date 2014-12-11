#!/bin/bash

check() {
	if [[ "$?" -eq 0 ]]; then
		echo -e "\033[32mOK\033[0m"
	else
		echo -e "\033[31mKO\033[0m"
		read -p "Press any key to pass this install"
		exit 1
	fi
}

# update package list and install iptables
echo -n "Install iptables: "
sudo apt-get -y install iptables
check

# authorise NAT
echo -n "Authorize NAT: "
sudo sed -ri s:^#net.ipv4.ip_forward=1$:net.ipv4.ip_forward=1: /etc/sysctl.conf
check

# reload sysctl conf
echo -n "Reload sysctl conf: "
sudo sysctl -p
check

# create iptables rules
echo -n "Create iptables rules: "
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE && \
sudo iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT && \
sudo iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT
check

# save iptables to file which will load after start
echo -n "Save iptables rules: "
sudo iptables-save > /etc/iptables.nat

# create a file with forwarding in /etc/network/if-up.d
echo -n "Create a file with forwarding: "
sudo cat > /etc/network/if-up.d/forwarding << EoF
#!/bin/sh
iptables-restore
EoF
check

# chmod +x previous file
echo -n "Give execution right to previously created script: "
sudo chmod +x /etc/network/if-up.d/forwarding
check
