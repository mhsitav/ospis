#!/bin/bash

# Setup System Settings
gsettings set org.gnome.settings-daemon.plugins.power idle-dim false;
sleep 2;
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing;
sleep 2;
gsettings set org.gnome.desktop.notifications show-banners false;

rm -- "$0"

reboot;
