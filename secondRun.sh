#!/bin/bash

sleep 90;

touch /opt/scripts/update.sh;
echo "#!/bin/bash" > /opt/scripts/update.sh;
echo "sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y;" >> /opt/scripts/update.sh;
echo "sleep 20;" >> /opt/scripts/update.sh;
echo "sudo reboot;" >> /opt/scripts/update.sh;
chmod +x /opt/scripts/update.sh;

crontab -u root -r;
(crontab -u root -l 2>/dev/null; echo "0 4 * * * /opt/scripts/update.sh") | crontab -u root -;
echo -e "$(crontab -u root -l)\n@reboot unclutter -idle 5 -root" | crontab -u root -;

crontab -u optisigns -r;
echo '@reboot /bin/bash -c "/opt/scripts/usSecondRun.sh"' | crontab -u optisigns -;

rm -- "$0";

sudo reboot;
