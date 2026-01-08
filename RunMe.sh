#!/bin/bash

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

wget -O "$OPTISIGNS_APPIMAGE" https://links.optisigns.com/linux-64
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
