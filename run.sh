#!/bin/bash

# Setup System Settings
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
gsettings set org.gnome.desktop.notifications show-banners false;

# Disable Wayland
sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/daemon.conf;
sed -i "/\[daemon\]/a AutomaticLoginEnable=true\nAutomaticLogin=optisigns" /etc/gdm3/daemon.conf

# Gnome Extensions
gnome-extensions install https://extensions.gnome.org/extension-data/no-overviewfthx.v21.shell-extension.zip;
gnome-extensions enable no-overview@fthx;


# Prep for Second Run
wget -P /opt/scripts <secondRun.sh>
chmod +x /opt/scripts/secondRun.sh

sudo crontab -u root -r;
(sudo crontab -u root -l 2>/dev/null; echo "@reboot sudo /opt/scripts/secondRun.sh") | sudo crontab -u root -

sudo reboot
