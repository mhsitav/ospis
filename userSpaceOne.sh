#!/bin/bash

set -euo pipefail

LOG_FILE="/var/log/mhs-post-install.log"
OPTISIGNS_USER="optisigns"
DOWNLOAD_DIR="/home/optisigns/Downloads"
OPTISIGNS_APPIMAGE="${DOWNLOAD_DIR}/linux-64"
DESKTOP_FILE="${AUTOSTART_DIR}/userspace.desktop"

exec > >(tee -a "$LOG_FILE") 2>&1

echo "===== MHS User Space Configuration Started: $(date) ====="

# Ensure running as optisigns user for GNOME settings
if [[ "$(id -un)" != "$OPTISIGNS_USER" ]]; then
  echo "ERROR: This script must be run as user '$OPTISIGNS_USER'"
  exit 1
fi

# -----------------------------
# GNOME System Settings
# -----------------------------
# Install GNOME extension
echo "Installing GNOME extension (no-overview-fthx)...";
gnome-extensions install https://extensions.gnome.org/extension-data/no-overviewfthx.v21.shell-extension.zip || echo "GNOME extension install failed (possibly already installed)";

echo "Configuring GNOME power and notification settings..."

gsettings set org.gnome.settings-daemon.plugins.power idle-dim false
sleep 1

gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type nothing
sleep 1

gsettings set org.gnome.desktop.notifications show-banners false

echo "GNOME power and notification settings applied."



# -----------------------------
# Cleanup
# -----------------------------
echo "Wipe autorun file and recreate..."
rm "$DESKTOP_FILE";

cat << 'EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Name=OptiSigns Startup
Comment=Launch OptiSigns at login
Exec=bash -c "sleep 10 && /opt/scripts/userSpaceTwo.sh"
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

echo "Removing runMeFirst setup script..."
rm -- "$0"

echo "===== MHS User Space Configuration 1/2 Completed: $(date) ====="
