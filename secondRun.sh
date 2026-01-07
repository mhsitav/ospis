#!/bin/bash

touch /opt/scripts/update.sh;
echo "#!/bin/bash" > /opt/scripts/update.sh;
echo "sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y;" >> /opt/scripts/update.sh;
echo "sleep 20;" >> /opt/scripts/update.sh;
echo "sudo reboot;" >> /opt/scripts/update.sh;
chmod +x /opt/scripts/update.sh;


sudo crontab -u root -r;
(sudo crontab -u root -l 2>/dev/null; echo "0 4 * * * /opt/scripts/update.sh") | sudo crontab -u root -;
echo -e "$(sudo crontab -u root -l)\n@reboot unclutter -idle 5 -root" | sudo crontab -u root -;

# Download and Install Optisigns (FINAL STEP)
export APPIMAGE_SILENT_INSTALL=0
wget -P /home/optisigns/Downloads https://links.optisigns.com/linux-64;
chmod +x /home/optisigns/Downloads/linux-64;
/home/optisigns/Downloads/linux-64 > /dev/null 2>&1 &
