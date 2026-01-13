#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/mhs-post-install.log"
OPTISIGNS_USER="optisigns"
HOME_DIR="/home/${OPTISIGNS_USER}"
DOWNLOAD_DIR="/home/optisigns/Downloads"
OPTISIGNS_APPIMAGE="${DOWNLOAD_DIR}/linux-64"
AUTOSTART_DIR="${HOME_DIR}/.config/autostart"
DESKTOP_FILE="${AUTOSTART_DIR}/userspace.desktop"
USER_TWO_SCRIPT="/opt/scripts/userSpaceTwo.sh"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== MHS User Space Configuration 2/2 Started: $(date) ====="

# -----------------------------
# GNOME Extensions
# -----------------------------
echo "Enabling GNOME extension: no-overview@fthx"

if gnome-extensions list | grep -q "no-overview@fthx"; then
  gnome-extensions enable no-overview@fthx
  echo "GNOME extension enabled."
else
  echo "WARNING: GNOME extension no-overview@fthx not found."
fi

# -----------------------------
# Download & Install OptiSigns
# -----------------------------
echo "Downloading OptiSigns AppImage..."

wget -q -O "$OPTISIGNS_APPIMAGE" https://links.optisigns.com/linux-64
chmod +x "$OPTISIGNS_APPIMAGE"

echo "Launching OptiSigns AppImage..."
export APPIMAGE_SILENT_INSTALL=0
"$OPTISIGNS_APPIMAGE" >/dev/null 2>&1 &

# -----------------------------
# Install OptiSigns Remote Agent
# -----------------------------
echo "Installing OptiSigns remote agent..."
curl -fsSL https://release.optisigns.com/optisigns-remote-agent-setup-linux.sh | sh >/dev/null 2>&1 &

echo "Removing userSpaceTwo setup script..."
rm -- "$0"

rm "$DESKTOP_FILE";

echo "Second-run script downloaded and permissions set."

# Configure user crontab safely
echo "Configuring user crontab..."
OPTISIGNS_CRON=$(crontab -u $(whoami) -l 2>/dev/null || true)

# Remove old second-run entries if present
OPTISIGNS_CRON=$(echo "$OPTISIGNS_CRON" | grep -v "linux-64" || true)

# Add reboot entry
OPTISIGNS_CRON=$(echo "$OPTISIGNS_CRON"; echo "@reboot $OPTISIGNS_APPIMAGE --no-sandbox")

echo "$OPTISIGNS_CRON" | crontab -u $(whoami) -

echo "User crontab configured for OptiSigns autostart."


echo "===== MHS User Space Configuration 2/2 Completed: $(date) ====="
echo "Rebooting";
/sbin/reboot;
