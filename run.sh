#!/bin/bash

# Install additional packages
sudo apt update && sudo apt upgrade -y;
sudo apt install -y libfuse2 fuse gnome-shell-extension-manager unclutter;

# Setup System Settings
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
gsettings set org.gnome.desktop.notifications show-banners false;

# Gnome Extensions
gnome-extensions install https://extensions.gnome.org/extension-data/no-overviewfthx.v21.shell-extension.zip;
gnome-extensions enable no-overview@fthx;

#Disable Wayland
sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/daemon.conf;

#Setup Autologin
sed -i "/\[daemon\]/a AutomaticLoginEnable=true\nAutomaticLogin=optisigns" /etc/gdm3/daemon.conf;

# Prep for Second Run
wget -P /opt/scripts https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/secondRun.sh
chmod +x /opt/scripts/secondRun.sh

sudo crontab -u root -r;
(sudo crontab -u root -l 2>/dev/null; echo "@reboot sudo /opt/scripts/secondRun.sh") | sudo crontab -u root -

sudo reboot
