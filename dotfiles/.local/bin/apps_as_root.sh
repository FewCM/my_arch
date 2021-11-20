#!/usr/bin/env bash

## rofi sudo askpass helper
export SUDO_ASKPASS=~/.local/bin/dwm/askpass.sh

## execute the application
sudo -A $1
