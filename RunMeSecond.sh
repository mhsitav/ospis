#!/bin/bash

gnome-extensions enable no-overview@fthx;

# Download and Install Optisigns (FINAL STEP)
export APPIMAGE_SILENT_INSTALL=0
wget -O /home/optisigns/Downloads/linux-64 https://links.optisigns.com/linux-64;
chmod +x /home/optisigns/Downloads/linux-64;
/home/optisigns/Downloads/linux-64 > /dev/null 2>&1 &
$(curl -s https://release.optisigns.com/optisigns-remote-agent-setup-linux.sh -L | sh) > /dev/null 2>&1 &

rm -- "$0";
