#!/bin/sh

# Prerequisites
# Ubuntu 22.04 server
# Root privileges
# A domain or sub-domain

# Set variables
HOST_NAME="meet"
WEBSITE_NAME="example.com"

# Retrieve the latest package versions across all repositories
sudo apt update && sudo apt upgrade -y

sudo apt-add-repository universe
sudo apt update

# Configure the Firewall with UFW
sudo ufw allow 80,443/tcp
sudo ufw allow 10000,5000/udp
sudo ufw allow 22/tcp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
sudo ufw enable
sudo ufw status

# Configure the hostname of the server corresponding to your domain or subdomain.
sudo hostnamectl set-hostname $HOST_NAME
sed -i 's/^127.0.1.1.*$/127.0.1.1 $HOST_NAME.$WEBSITE_NAME $HOST_NAME/g' /etc/hosts
sed -i 's/^127.0.0.1.*$/127.0.0.1 localhost $HOST_NAME.$WEBSITE_NAME $HOST_NAM/g' /etc/hosts

# Ensure support for apt repositories served via HTTPS
sudo apt install gnupg2 apt-transport-https nano curl wget nginx certbot net-tools -y

sudo systemctl start nginx.service
sudo systemctl enable nginx.service

# Add the Jitsi package repository
curl https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null

# Add the Prosody package repository
echo deb http://packages.prosody.im/debian $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list
wget https://prosody.im/files/prosody-debian-packages.key -O- | sudo apt-key add -
sudo apt install lua5.2 -y

# Update your package list
sudo apt update

# jitsi-meet installation
sudo apt install jitsi-meet -y

# Verify jitsi-videobridge2 installation.:
systemctl restart jitsi-videobridge2

# Obtaining a Signed TLS Certificate
# sudo /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

# Jitsi Customization
# Config File:- /etc/jitsi/meet/[your-domain]-config.js
/etc/jitsi/meet/meet.ultimateakash.tech-config.js

# Interface Config File:- /usr/share/jitsi-meet/interface_config.js
/usr/share/jitsi-meet/interface_config.js

# Remove Jitsi Logo
SHOW_JITSI_WATERMARK: false

# You can customize the jitsi by modifing the config files properties.

# Samples files:
# https://github.com/jitsi/jitsi-meet/blob/master/config.js
# https://github.com/jitsi/jitsi-meet/blob/master/interface_config.js
