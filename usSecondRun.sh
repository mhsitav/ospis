#!/bin/bash

gnome-extensions enable no-overview@fthx;

crontab -u optisigns -r;

rm -- "$0";
