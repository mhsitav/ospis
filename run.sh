#!/bin/bash

touch /var/log/mhs-setup.log;

echo "Log file created. Starting Post-Install." >> /var/log/mhs-setup.log;
sleep 2;
# Install additional packages
sudo apt update && sudo apt upgrade -y;
echo "Repos updated and existing packages upgraded." >> /var/log/mhs-setup.log;
sleep 2;
$(sudo apt install -y libfuse2 fuse gnome-shell-extension-manager unclutter wget) >> /var/log/mhs-setup.log;
sleep 5;

# Prep for Second Run
echo "Downloading second run script." >> /var/log/mhs-setup.log;
wget -O /opt/scripts/secondRun.sh https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/secondRun.sh;
chmod +x /opt/scripts/secondRun.sh;

# Set crontabs
sudo crontab -u root -r;
sudo crontab -u root -l 2>/dev/null; 
echo "@reboot sudo /opt/scripts/secondRun.sh" | sudo crontab -u root -;
echo "Set crontab for second run script. Deleting run.sh and rebooting." >> /var/log/mhs-setup.log;

chmod -R 777 /opt/scripts;

rm -- "$0";

sudo reboot;
