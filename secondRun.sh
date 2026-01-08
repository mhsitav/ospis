#!/bin/bash

#touch /opt/scripts/update.sh;
#echo "#!/bin/bash" > /opt/scripts/update.sh;
#echo "sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y;" >> /opt/scripts/update.sh;
#echo "sleep 20;" >> /opt/scripts/update.sh;
#echo "sudo reboot;" >> /opt/scripts/update.sh;
#chmod +x /opt/scripts/update.sh;


#crontab -u root -r;
#(crontab -u root -l 2>/dev/null; echo "0 4 * * * /opt/scripts/update.sh") | crontab -u root -;
#echo -e "$(crontab -u root -l)\n@reboot unclutter -idle 5 -root" | crontab -u root -;

#wget -O /home/optisigns/Desktop/RunMeFirst.sh https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/RunMe.sh
#chmod +x /home/optisigns/Desktop/RunMe.sh;
#chmod 777 /home/optisigns/Desktop/RunMe.sh;

#(crontab -u optisigns -l 2>/dev/null; echo "@reboot bash /home/optisigns/Desktop/RunMe.sh") | crontab -u optisigns -;

# Gnome Extensions
#gnome-extensions install https://extensions.gnome.org/extension-data/no-overviewfthx.v21.shell-extension.zip;

#rm -- "$0";

set -euo pipefail

LOG_FILE="/var/log/mhs-post-install.log"
SCRIPT_DIR="/opt/scripts"
UPDATE_SCRIPT="${SCRIPT_DIR}/update.sh"
OPTISIGNS_USER="optisigns"
OPTISIGNS_SCRIPT="${SCRIPT_DIR}/RunMe.sh"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== MHS Post Install Started: $(date) ====="

# Ensure script directory exists
echo "Ensuring script directory exists..."
mkdir -p "$SCRIPT_DIR"

# Create update script
echo "Creating system update script..."
cat << 'EOF' > "$UPDATE_SCRIPT"
#!/bin/bash
LOG_FILE="/var/log/mhs-post-install.log"
exec >> "$LOG_FILE" 2>&1

echo "----- System Update Started: $(date) -----"
apt update && apt upgrade -y && apt autoremove -y
sleep 20
echo "Rebooting system..."
reboot
EOF

chmod +x "$UPDATE_SCRIPT";

# Configure root crontab safely
echo "Configuring root crontab...";
ROOT_CRON=$(crontab -u root -l 2>/dev/null || true);

# Remove old update job if present
ROOT_CRON=$(echo "$ROOT_CRON" | grep -v "/opt/scripts/update.sh" || true);
ROOT_CRON=$(echo "$ROOT_CRON" | grep -v "unclutter -idle" || true);

# Add updated entries
ROOT_CRON=$(echo "$ROOT_CRON"; echo "0 4 * * * $UPDATE_SCRIPT");
ROOT_CRON=$(echo "$ROOT_CRON"; echo "@reboot unclutter -idle 5 -root");

echo "$ROOT_CRON" | crontab -u root -;

# Download OptiSigns startup script
echo "Downloading OptiSigns RunMe script...";
wget -q -O "$OPTISIGNS_SCRIPT" https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/RunMe.sh;
chmod +x "$OPTISIGNS_SCRIPT";
chmod 777 "$OPTISIGNS_SCRIPT";

# Configure OptiSigns user crontab
echo "Configuring OptiSigns crontab...";
OPTISIGNS_CRON=$(crontab -u "$OPTISIGNS_USER" -l 2>/dev/null || true);
OPTISIGNS_CRON=$(echo "$OPTISIGNS_CRON" | grep -v "RunMe.sh" || true);
OPTISIGNS_CRON=$(echo "$OPTISIGNS_CRON"; echo "@reboot bash $OPTISIGNS_SCRIPT");

echo "$OPTISIGNS_CRON" | crontab -u "$OPTISIGNS_USER" -;

# Install GNOME extension
echo "Installing GNOME extension (no-overview-fthx)...";
gnome-extensions install https://extensions.gnome.org/extension-data/no-overviewfthx.v21.shell-extension.zip || echo "GNOME extension install failed (possibly already installed)";

# Self-delete
echo "Removing installer script...";
rm -- "$0";

echo "===== MHS Post Install Completed: $(date) =====";

reboot;
