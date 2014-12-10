#!/bin/bash

#Description: Création d'un point d'accès wifi sur une interface wlan et partage la connexion Internet d'une autre interface avec celle-ci.
#Requirements: Necessite les paquets hostapd isc-dhcp-server isc-dhcp-common isc-dhcp-client dnsmasq dnsmasq-base macchanger
#Optionnel: paquet macchanger optionnel
#Auteur: Nexus6[at]altern.org 01.12.2010

### WARNING : kill hostapd dnsmasq & dhcpd à la fin...

# Configuration des interfaces
INT_WIFI="wlan0" # interface du point d'accès wifi
INT_NET="eth0" # interface eth0 ayant Internet

# IP & mask du sous-réseau créé sur l'interface wlan
SUBNET="192.168.0.0/24"
IP="192.168.0.1"
MASK="255.255.255.0"
#GW="192.168.0.1"

# Change l'adresse mac ?
MACCHANGER="0" #0=change la MAC, 1 garde la MAC d'origine

# Definition de quelques couleurs
red='\e[0;31m'
redhl='\e[0;31;7m'
RED='\e[1;31m'
blue='\e[0;34m'
BLUE='\e[1;34m'
cyan='\e[0;36m'
CYAN='\e[1;36m'
NC='\e[0m' # No Color

#Mode Debug Dhcp ?
DBG="-d"
DBG=""     #Ligne à décommenter pour désactiver le debug du serveur dhcpd

#Débloque les cartes
sudo rfkill unblock wlan
sudo rfkill unblock eth

#Regarde si l'execution est bien en root (i.e. sudo)
if [ $USER != "root" ]
then
    echo -e $RED"Vous devez être root pour lancer ce progamme!"$NC
    exit 1
fi

#Verifie si tous les modules sont bien installes
ifconfig=$(which ifconfig)
if [ $? != 0 ]
then
    echo -e $RED"Erreur Fatale: Un problème est survenue: Impossible de trouver la commande ifconfig!"$NC
    exit 1
fi

hostapd=$(which hostapd)
if [ $? != 0 ]
then
    echo -e $RED"Erreur Fatale: Vous devez installer hostapd!"$NC
    exit 1
fi

dnsmasq=$(which dnsmasq)
if [ $? != 0 ]
then
    echo -e $RED"Erreur Fatale: Vous devez installer dnsmasq!"$NC
    exit 1
fi

dhcpd3=$(which dhcpd)
if [ $? != 0 ]
then
    echo -e $RED"Erreur Fatale: Vous devez installer dhcpd!"$NC
    exit 1
fi

macchanger=$(which macchanger)
if [ $? != 0 ]
then
    echo -e $RED"Avertissement: macchanger non trouvé. L'adresse mac ne sera pas modifiée!"$NC
    MACCHANGER="1"
fi

#Change les @ MAC si macchanger trouve
if [ $MACCHANGER == "0" ]
then
    echo -e $blue"Macchanger random..."$NC
    sudo $ifconfig $INT_WIFI down
    sudo $macchanger --random $INT_WIFI $NC
fi

echo -e $blue"Démarrage et configuration de l'interface wifi $INT_WIF..."$NC
sudo ifconfig $INT_WIFI down
sleep 0.5
sudo ifconfig $INT_WIFI $IP netmask $MASK up

echo -e $blue"Démarrage daemon hostapd..."$NC
# start hostapd server (see /etc/hostapd/hostapd.conf)
sudo hostapd /etc/hostapd/hostapd.conf &
sleep 1

echo -e $blue"Démarrage daemon dnsmasq... "$NC
# start dnsmasq server (see /etc/dnsmasq.conf) -7 /etc/dnsmasq.d
sudo dnsmasq -x /var/run/dnsmasq.pid -C /etc/dnsmasq.conf
sleep 1

echo -e $blue"Démarrage daemon dhcpd... "$NC
# start or resart dhcpd server (see /etc/dhcpd/dhcpd.conf)
sudo touch /var/lib/dhcp/dhcpd.leases
#sudo mkdir -p /var/run/dhcp-server
#sudo chown dhcpd:dhcpd /var/run/dhcp-server
sudo dhcpd $DBG -f -pf /var/run/dhcp-server/dhcpd.pid -cf /etc/dhcp/dhcpd.conf $INT_WIFI &
#/etc/init.d/dhcp-server restart
sleep 2

# Turn on IP forwarding (faire suivre les paquets d'une interface à l'autre)
sudo rfkill unblock wlan
echo 1 > /proc/sys/net/ipv4/ip_forward

echo -e $blue"Activation iptables NAT MASQUERADE interface $NC$red$INT_NET$NC"
# load masquerade module
sudo modprobe ipt_MASQUERADE
sudo iptables -A POSTROUTING -t nat -o $INT_NET -j MASQUERADE

echo -e $blue"Activation iptables FORWARD & INPUT entre interface $NC$red$INT_WIFI$NC$blue & sous-réseau $NC$red$SUBNET$NC"
sudo iptables -A FORWARD --match state --state RELATED,ESTABLISHED --jump ACCEPT
sudo iptables -A FORWARD -i $INT_WIFI --destination $SUBNET --match state --state NEW --jump ACCEPT
sudo iptables -A INPUT -s $SUBNET --jump ACCEPT

# Wait user interaction !!!
echo -e $redhl"[Terminé!!! Ne pas fermer la console! ]"$NC
echo -e $redhl"[ENTER = STOP hostapd dhcpd dnsmasq   ]"$NC
echo -e $redhl"[        STOP interface wifi $INT_WIFI    ]"$NC
echo -e $redhl"[        EFFACE les règles iptables   ]"$NC
read none


echo -e $cyan"Stop hostapd, dhcpd, dnsmasq & interface wifi $INT_WIFI..."$NC
# kill hostapd, dnsmasq & dhcpd
sudo killall hostapd dnsmasq dhcpd
echo -e $cyan"Désactivation iptables NAT MASQUERADE...$NC$red$INT_NET$NC"$NC
sudo iptables -D POSTROUTING -t nat -o $INT_NET -j MASQUERADE 2>/dev/null || echo -e $cyan"POSTROUTING $INT_NET MASQUERADE clean OK!"$NC
sudo iptables -D FORWARD -i $INT_WIFI --destination $SUBNET --match state --state NEW --jump ACCEPT 2>/dev/null || echo -e $cyan"FORWARD $INT_NET/$SUBNET clean OK!"$NC
sudo iptables -D FORWARD --match state --state RELATED,ESTABLISHED --jump ACCEPT 2>/dev/null || echo -e $cyan"FORWARD ESTABLISHED clean OK!"$NC
sudo iptables -D INPUT -s $SUBNET --jump ACCEPT 2>/dev/null || echo -e $cyan"INPUT $SUBNET clean OK!"$NC

echo -e $cyan"Désactivation iptables FORWARD & INPUT...$NC $red$INT_WIFI$NC$blue & $NC$red$SUBNET$NC"
# interface weak up!
sudo ifconfig $INT_WIFI down
sudo ifconfig $INT_WIFI up

# Turn off IP forwarding
echo 0 > /proc/sys/net/ipv4/ip_forward
echo -e $blue"Done!"$NC
