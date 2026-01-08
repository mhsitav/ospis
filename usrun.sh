#!/bin/bash

# Setup System Settings
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false;
sleep 2;
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing;
sleep 2;
gsettings set org.gnome.desktop.notifications show-banners false;

# Gnome Extensions
gnome-extensions install https://extensions.gnome.org/extension-data/no-overviewfthx.v21.shell-extension.zip;

# Download UserSpace Second Run

# Enable UserSpace Second Run
crontab -u optisigns -r;
crontab -u optisigns -l 2>/dev/null;
echo "@reboot /opt/scripts/usSecondRun.sh" | crontab -u optisigns -;

rm -- "$0"
