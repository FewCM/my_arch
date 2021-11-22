#!/bin/bash

DIR="$HOME/.config"

rofi_command="rofi -theme $DIR/rofi/$DESKTOP_SESSION/themes/asroot.rasi"

# Apps
terminal=" Alacritty"
ST=" ST"
files=" Thunar"
editor=" Geany"
clifm=" lf"
vim=" Vim"

# Variable passed to rofi
options="$terminal\n$ST\n$files\n$editor\n$clifm\n$vim"

# Functions
chosen="$(echo -e "$options" | $rofi_command -p "Run as root(#)" -dmenu -selected-row 0)"
case $chosen in
    $terminal)
        $HOME/.local/bin/apps_as_root.sh 'alacritty --class alacritty-float,alacritty-float --config-file $HOME/.config/alacritty/$DESKTOP_SESSION/alacritty.yml'
        ;;
    $ST)
        $HOME/.local/bin/apps_as_root.sh 'st'
        ;;
    $files)
        $HOME/.local/bin/apps_as_root.sh 'dbus-run-session thunar'
        ;;
    $editor)
        $HOME/.local/bin/apps_as_root.sh geany
        ;;
    $clifm)
        $HOME/.local/bin/apps_as_root.sh 'st -e lf'
        ;;
    $vim)
        $HOME/.local/bin/apps_as_root.sh 'st -e vim'
        ;;
esac


