#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/mhs-post-install.log"
SCRIPT_DIR="/opt/scripts"
SECOND_RUN_SCRIPT="${SCRIPT_DIR}/secondRun.sh"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== MHS Setup Started: $(date) ====="

# Ensure directories exist
#echo "Ensuring required directories exist..."
sudo mkdir -p "$SCRIPT_DIR"
sudo chmod -R 777 "$SCRIPT_DIR"
sudo touch "$LOG_FILE"
sudo chmod 777 "$LOG_FILE"

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
  wget \
  curl

echo "Package installation completed."

sleep 2

# Download second-run script
echo "Downloading second-run script..."
sudo wget -q -O "$SECOND_RUN_SCRIPT" \
  https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/secondRun.sh

sudo chmod +x "$SECOND_RUN_SCRIPT"
sudo chmod 777 "$SECOND_RUN_SCRIPT"

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

sudo reboot
