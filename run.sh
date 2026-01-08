#!/bin/bash
sleep 2;
# Install additional packages
sudo apt update && sudo apt upgrade -y;
sleep 2;
sudo apt install -y libfuse2 fuse gnome-shell-extension-manager unclutter;
sleep 5;

# Prep for Second Run
wget -P /opt/scripts https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/secondRun.sh;
chmod +x /opt/scripts/secondRun.sh;

wget -P /opt/scripts https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/usrun.sh;
chmod +x /opt/scripts/usrun.sh;

sudo crontab -u root -r;
(sudo crontab -u root -l 2>/dev/null; echo "@reboot sudo /opt/scripts/secondRun.sh") | sudo crontab -u root -;

(sudo crontab -u optisigns -l 2>/dev/null; echo "@reboot /opt/scripts/usrun.sh") | sudo crontab -u optisigns -;

sudo reboot;
