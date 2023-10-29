#!/bin/sh

# Prerequisites
# Ubuntu 20.04 server
# Root privileges
# A domain or sub-domain

# Retrieve the latest package versions across all repositories
sudo apt update && sudo apt upgrade -y

# Ensure support for apt repositories served via HTTPS
sudo apt install apt-transport-https -y

sudo apt-add-repository universe
sudo apt update

sudo hostnamectl set-hostname meet.smartbs.co.ug

# Check that this was successful by running the following:
hostname

#Next, you will set a local mapping of the server’s hostname to the loopback IP address, 127.0.0.1. Do this by opening the /etc/hosts with a text editor:

sudo nano /etc/hosts

#Then, add the following line:

127.0.0.1 localhost
192.168.1.70 meet.smartbs.co.ug

#Configuring the Firewall

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 10000/udp
sudo ufw allow 22/tcp
sudo ufw allow 3478/udp
sudo ufw allow 5349/tcp
sudo ufw enable
sudo ufw status

# Add the Prosody package repository
echo deb http://packages.prosody.im/debian $(lsb_release -sc) main | sudo tee -a /etc/apt/sources.list
wget https://prosody.im/files/prosody-debian-packages.key -O- | sudo apt-key add -
sudo apt install lua5.2 -y

# Add the Jitsi package repository
curl https://download.jitsi.org/jitsi-key.gpg.key | sudo sh -c 'gpg --dearmor > /usr/share/keyrings/jitsi-keyring.gpg'
echo 'deb [signed-by=/usr/share/keyrings/jitsi-keyring.gpg] https://download.jitsi.org stable/' | sudo tee /etc/apt/sources.list.d/jitsi-stable.list > /dev/null

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
sudo nano /etc/prosody/conf.avail/meet.smartbs.co.ug.cfg.lua

#Edit this line:
        authentication = "anonymous" to
      
# Then, in the same file, add the following section to the end of the file:
VirtualHost "guest.meet.smartbs.co.ug"
    authentication = "anonymous"
  
    
 sudo nano /etc/jitsi/meet/meet.smartbs.co.ug-config.js
# And add the following line to complete the configuration changes:
org.jitsi.jicofo.auth.URL...

sudo prosodyctl register user meet.smartbs.co.ug password

# Finally, restart the Jitsi Meet processes to load the new configuration:

sudo systemctl restart prosody.service

sudo systemctl restart jitsi-videobridge2.service
       
