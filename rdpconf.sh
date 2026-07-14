#!/bin/bash
IFACE=$(ls /sys/class/net | grep -E "^en" | head -n1);
MAC=$(cat /sys/class/net/$IFACE/address | tr -d ":");

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
rm ~/.local/share/keyrings/*;
mkdir -p ~/.local/share/gnome-remote-desktop/;

grdctl --headless rdp set-credentials optisigns Opti$MAC;

openssl req -newkey rsa:2048 -nodes \
  -keyout ~/.local/share/gnome-remote-desktop/tls.key \
  -x509 -days 730 \
  -out ~/.local/share/gnome-remote-desktop/tls.crt \
  -subj "/CN=debian-remote-desktop"

grdctl rdp set-tls-key ~/.local/share/gnome-remote-desktop/tls.key
grdctl rdp set-tls-cert ~/.local/share/gnome-remote-desktop/tls.crt

gsettings set org.gnome.desktop.remote-desktop.rdp enable true
gsettings set org.gnome.desktop.remote-desktop.rdp view-only false
