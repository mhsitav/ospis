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
IFACE=$(ls /sys/class/net | grep -E "^en" | head -n1);
MAC=$(cat /sys/class/net/$IFACE/address | tr -d ":");

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
# Configure RDP
# -----------------------------
python3 -c '
import dbus
bus = dbus.SessionBus()
try:
    secrets = bus.get_object("org.freedesktop.secrets", "/org/freedesktop/secrets")
    service = dbus.Interface(secrets, "org.freedesktop.Secret.Service")
    
    props = {"org.freedesktop.Secret.Collection.Label": "DefaultKeyring"}
    service.CreateCollection(props, "")
    print("Successfully created keychain")
except Exception as e:
    print(f"Error: {e}")
'

mkdir -p ~/.local/share/gnome-remote-desktop/;

openssl req -newkey rsa:2048 -nodes \
  -keyout ~/.local/share/gnome-remote-desktop/tls.key \
  -x509 -days 730 \
  -out ~/.local/share/gnome-remote-desktop/tls.crt \
  -subj "/CN=debian-remote-desktop"

grdctl rdp set-tls-key ~/.local/share/gnome-remote-desktop/tls.key
grdctl rdp set-tls-cert ~/.local/share/gnome-remote-desktop/tls.crt

grdctl rdp set-credentials optisigns Opti$MAC;
gsettings set org.gnome.desktop.remote-desktop.rdp enable true
gsettings set org.gnome.desktop.remote-desktop.rdp view-only false

# -----------------------------
# Download userSpaceTwo
# -----------------------------
echo "Downloading User Space Two script...";
wget -q -O "$USER_TWO_SCRIPT" https://raw.githubusercontent.com/mhsitav/ospis/refs/heads/main/userSpaceTwo.sh;
chmod +x "$USER_TWO_SCRIPT";

# -----------------------------
# Cleanup
# -----------------------------
echo "Wipe autorun file and recreate..."
rm "$DESKTOP_FILE";

cat << 'EOF' > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Name=User Space Script Two autolaunch
Comment=Launch User Space script two at login
Exec=bash -c "sleep 10 && /opt/scripts/userSpaceTwo.sh"
Terminal=false
X-GNOME-Autostart-enabled=true
EOF

echo "Removing userSpaceOne setup script..."
rm -- "$0"

echo "===== MHS User Space Configuration 1/2 Completed: $(date) ====="
/sbin/reboot;
