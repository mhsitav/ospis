#!/bin/bash

sleep 2;
# Install additional packages
sudo apt update && sudo apt upgrade -y;
sleep 2;
sudo apt install -y libfuse2 fuse gnome-shell-extension-manager unclutter wget;
sleep 5;

# Prep for Second Run
wget -O /opt/scripts/secondRun.sh https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/secondRun.sh;
chmod +x /opt/scripts/secondRun.sh;

wget -O /opt/scripts/usrun.sh https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/usrun.sh;
chmod +x /opt/scripts/usrun.sh;

wget -O /opt/scripts/usSecondRun.sh https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/usSecondRun.sh;
chmod +x /opt/scripts/usSecondRun.sh;

# Set crontabs
sudo crontab -u root -r;
sudo crontab -u root -l 2>/dev/null; 
echo "@reboot sudo /opt/scripts/secondRun.sh" | sudo crontab -u root -;

echo '"@reboot /bin/bash -c "/opt/scripts/usrun.sh"' | sudo crontab -u optisigns -;

chmod -R 777 /opt/scripts;

rm -- "$0";

sudo reboot;
