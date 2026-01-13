#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/mhs-post-install.log"
OPTISIGNS_USER="optisigns"
HOME_DIR="/home/${OPTISIGNS_USER}"
SCRIPT_DIR="/opt/scripts"
UPDATE_SCRIPT="${SCRIPT_DIR}/update.sh"
OPTISIGNS_USER="optisigns"
USER_ONE_SCRIPT="${SCRIPT_DIR}/userSpaceOne.sh"
AUTOSTART_DIR="${HOME_DIR}/.config/autostart"
DESKTOP_FILE="${AUTOSTART_DIR}/userspace.desktop"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== MHS Post Install Started: $(date) ====="

# Ensure script directory exists
echo "Ensuring script directory exists..."
sudo mkdir -p "$SCRIPT_DIR"

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
sudo reboot
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
echo "Downloading User space script one...";
wget -q -O "$USER_ONE_SCRIPT" https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/userSpaceOne.sh;
echo "Setting permissions for script...";
chmod +x "$USER_ONE_SCRIPT";

echo "Creating GNOME autostart entry...";

sudo mkdir -p "$AUTOSTART_DIR"

cat << 'EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Name=OptiSigns Startup
Comment=Launch OptiSigns at login
Exec=bash -c "sleep 10 && /opt/scripts/userSpaceOne.sh"
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

sudo chown -R "${OPTISIGNS_USER}:${OPTISIGNS_USER}" "${HOME_DIR}/.config"
sudo chmod 644 "$DESKTOP_FILE";

# Make reboot command sudo-less
echo 'optisigns ALL=NOPASSWD:/sbin/reboot' | sudo EDITOR='tee -a' visudo

# Self-delete
echo "Removing installer script...";
rm -- "$0";

echo "Autostart entry created:"
cat "$DESKTOP_FILE"

echo "Second run completed. Changes will take effect on next login."
echo "===== MHS Post Install Completed: $(date) =====";

sudo reboot;
