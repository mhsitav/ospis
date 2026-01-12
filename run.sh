#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/mhs-post-install.log"
SCRIPT_DIR="/opt/scripts"
SECOND_RUN_SCRIPT="${SCRIPT_DIR}/secondRun.sh"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== MHS Setup Started: $(date) ====="

echo "Setting hostname and password...";
IFACE=$(ls /sys/class/net | grep -E "^en" | head -n1);
MAC=$(cat /sys/class/net/$IFACE/address | tr -d ":");
HOST="optisigns-mhs-$(echo -n $MAC | tail -c 6)";
PASS="Opti$MAC";

echo "$HOST" > /etc/hostname;
sed -i "s/127.0.1.1.*/127.0.1.1\t$HOST/" /etc/hosts;
echo 'optisigns:$PASS' | chpasswd;
sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm3/daemon.conf;
sed -i "/\[daemon\]/a AutomaticLoginEnable=true\nAutomaticLogin=optisigns" /etc/gdm3/daemon.conf;

# Ensure directories exist
echo "Ensuring required directories exist..."
mkdir -p "$SCRIPT_DIR"
touch "$LOG_FILE"
chmod 777 "$LOG_FILE"

# Update system
echo "Updating repositories and upgrading packages..."
apt update
apt upgrade -y
echo "System update completed."

# Install required packages
echo "Installing required packages..."
apt install -y \
  libfuse2 \
  fuse \
  gnome-shell-extension-manager \
  unclutter \
  curl

echo "Package installation completed."

sleep 2

# Download second-run script
echo "Downloading second-run script..."
wget -q -O "$SECOND_RUN_SCRIPT" \
  https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/secondRun.sh

chmod +x "$SECOND_RUN_SCRIPT"
chmod 755 "$SECOND_RUN_SCRIPT"

echo "Second-run script downloaded and permissions set."

# Configure root crontab safely
echo "Configuring root crontab..."
ROOT_CRON=$(crontab -u root -l 2>/dev/null || true)

# Remove old second-run entries if present
ROOT_CRON=$(echo "$ROOT_CRON" | grep -v "secondRun.sh" || true)

# Add reboot entry
ROOT_CRON=$(echo "$ROOT_CRON"; echo "@reboot $SECOND_RUN_SCRIPT")

echo "$ROOT_CRON" | crontab -u root -

echo "Root crontab configured for second-run script."

# Cleanup and reboot
echo "Removing first-run script..."
rm -- "$0"

echo "Rebooting system to trigger second-run script..."
echo "===== MHS Setup Completed: $(date) ====="

reboot
