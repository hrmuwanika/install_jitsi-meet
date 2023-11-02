#!/bin/sh

# Prerequisites
# Ubuntu 22.04 server
# Root privileges
# A domain or sub-domain

# Set website domain
WEBSITE_NAME="meet.example.com"

# Retrieve the latest package versions across all repositories
sudo apt update && sudo apt upgrade -y

sudo apt-add-repository universe
sudo apt update

# Ensure support for apt repositories served via HTTPS
sudo apt install gnupg2 apt-transport-https nano curl wget lua5.2 -y

sudo hostnamectl set-hostname $WEBSITE_NAME

# Check that this was successful by running the following:
hostname
# Next, you will set a local mapping of the server’s hostname to the loopback IP address, 127.0.0.1. Do this by opening the /etc/hosts with a text editor:

sudo nano /etc/hosts

# Then, add the following line:
127.0.0.1 $WEBSITE_NAME

# Configure the Firewall with UFW
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 10000/udp
sudo ufw allow 22/tcp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
sudo ufw enable
sudo ufw status

# Add the Jitsi package repository
curl https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null

# Add the Prosody package repository
echo deb http://packages.prosody.im/debian $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list
wget https://prosody.im/files/prosody-debian-packages.key -O- | sudo apt-key add -

# Update your package list
sudo apt update

# jitsi-meet installation
sudo apt install jitsi-meet -y

sudo apt -y install jitsi-videobridge
sudo apt -y install jicofo
sudo apt -y install jigasi

sudo apt -y install certbot

# Obtaining a Signed TLS Certificate
sudo /usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

# Locking Conference Creation
sudo nano /etc/prosody/conf.avail/$WEBSITE_NAME.cfg.lua

#Edit this line:
        authentication = "anonymous" to
      
# Then, in the same file, add the following section to the end of the file:
VirtualHost "guest.$WEBSITE_NAME"
    authentication = "anonymous"
  
 sudo nano /etc/jitsi/meet/$WEBSITE_NAME-config.js
# And add the following line to complete the configuration changes:
org.jitsi.jicofo.auth.URL...

echo -e "\n========= Generating random admin password ==========="
JITSI_PASSWD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 20 | head -n 1)
    
sudo prosodyctl register user $WEBSITE_NAME $JITSI_PASSWD

# Finally, restart the Jitsi Meet processes to load the new configuration:

sudo systemctl restart prosody.service
sudo systemctl restart jicofo.service
sudo systemctl restart jitsi-videobridge2.service
       
echo "Your website address is: $WEBSITE_NAME"
echo "Your Jitsi password is: $JITSI_PASSWD"
