#!/usr/bin/env bash
rofi -dmenu\
     -password\
     -i\
     -no-fixed-num-lines\
     -p "Root Password: "\
     -theme $HOME/.config/rofi/$DESKTOP_SESSION/themes/askpass.rasi &
