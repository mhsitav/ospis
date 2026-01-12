#!/bin/bash

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

echo "OptiSigns installation started."
echo "===== MHS User Space Configuration 2/2 Completed: $(date) ====="
echo "Rebooting";
reboot
