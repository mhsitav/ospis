#!/bin/bash

# Setup System Settings
#gsettings set org.gnome.settings-daemon.plugins.power idle-dim false;
#sleep 2;
#gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing;
#sleep 2;
#gsettings set org.gnome.desktop.notifications show-banners false;

#gnome-extensions enable no-overview@fthx;

# Download and Install Optisigns (FINAL STEP)
#export APPIMAGE_SILENT_INSTALL=0
#wget -O /home/optisigns/Downloads/linux-64 https://links.optisigns.com/linux-64;
#chmod +x /home/optisigns/Downloads/linux-64;
#/home/optisigns/Downloads/linux-64 > /dev/null 2>&1 &
#$(curl -s https://release.optisigns.com/optisigns-remote-agent-setup-linux.sh -L | sh) > /dev/null 2>&1 &

#rm -- "$0";

set -euo pipefail

LOG_FILE="/var/log/mhs-post-install.log"
OPTISIGNS_USER="optisigns"
DOWNLOAD_DIR="/home/optisigns/Downloads"
OPTISIGNS_APPIMAGE="${DOWNLOAD_DIR}/linux-64"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== MHS Final Configuration Started: $(date) ====="

# Ensure running as optisigns user for GNOME settings
if [[ "$(id -un)" != "$OPTISIGNS_USER" ]]; then
  echo "ERROR: This script must be run as user '$OPTISIGNS_USER'"
  exit 1
fi

# -----------------------------
# GNOME System Settings
# -----------------------------
echo "Configuring GNOME power and notification settings..."

gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
sleep 1

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
sleep 1

gsettings set org.gnome.desktop.notifications show-banners false

echo "GNOME power and notification settings applied."

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

mkdir -p "$DOWNLOAD_DIR"

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

echo "OptiSigns installation started."

# -----------------------------
# Cleanup
# -----------------------------
echo "Removing final setup script..."
rm -- "$0"

echo "===== MHS Final Configuration Completed: $(date) ====="
