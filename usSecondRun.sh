#!/bin/bash

gnome-extensions enable no-overview@fthx;

crontab -r;
echo "@reboot /home/optisigns/Downloads/linux-64" | crontab -



rm -- "$0";
