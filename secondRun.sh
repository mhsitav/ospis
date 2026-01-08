#!/bin/bash

touch /opt/scripts/update.sh;
echo "#!/bin/bash" > /opt/scripts/update.sh;
echo "sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y;" >> /opt/scripts/update.sh;
echo "sleep 20;" >> /opt/scripts/update.sh;
echo "sudo reboot;" >> /opt/scripts/update.sh;
chmod +x /opt/scripts/update.sh;

crontab -u root -r;
(crontab -u root -l 2>/dev/null; echo "0 4 * * * /opt/scripts/update.sh") | crontab -u root -;
echo -e "$(crontab -u root -l)\n@reboot unclutter -idle 5 -root" | crontab -u root -;

wget -O /home/optisigns/Desktop/RunMeFirst.sh https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/RunMe.sh
chmod +x /home/optisigns/Desktop/RunMe.sh;
chmod 777 /home/optisigns/Desktop/RunMe.sh;

(crontab -u optisigns -l 2>/dev/null; echo "@reboot bash /home/optisigns/Desktop/RunMe.sh") | crontab -u optisigns -;

# Gnome Extensions
gnome-extensions install https://extensions.gnome.org/extension-data/no-overviewfthx.v21.shell-extension.zip;

rm -- "$0";
