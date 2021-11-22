#!/usr/bin/env bash

## Author  : Aditya Shakya
## Mail    : adi1090x@gmail.com
## Github  : @adi1090x
## Twitter : @adi1090x

rofi_command="rofi -theme $HOME/.config/rofi/$DESKTOP_SESSION/themes/powermenu.rasi"
#rofi_command="/home/fewcm/Projects/rofi/build/rofi -theme ~/.config/rofi/themes/powermenu.rasi"

uptime=$(uptime -p | sed -e 's/up //g')
cpu=$(sh $HOME/.config/rofi/$DESKTOP_SESSION/bin/usedcpu.sh)
memory=$(sh $HOME/.config/rofi/$DESKTOP_SESSION/bin/usedram.sh)

# Options
shutdown=""
reboot=""
lock=""
suspend=""
logout=""

# Confirmation
confirm_exit() {
	rofi -dmenu\
		-i\
		-no-fixed-num-lines\
		-p "Are You Sure? : "\
		-theme $HOME/.config/rofi/$DESKTOP_SESSION/themes/confirm.rasi
}


# Variable passed to rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"

chosen="$(echo -e "$options" | $rofi_command -p "祥 $uptime |  $cpu | ﬙ $memory " -dmenu -selected-row 2)"
case $chosen in
    $shutdown)
		systemctl poweroff
        ;;
    $reboot)
		systemctl reboot
        ;;
    $lock)
		if [[ -f /usr/bin/i3lock ]]; then
			i3lock
		elif [[ -f /usr/bin/betterlockscreen ]]; then
			betterlockscreen -l
		fi
        ;;
    $suspend)
		mpc -q pause
		amixer set Master mute
		systemctl suspend
        ;;
    $logout)
		kill -TERM $(pidof dwm)
        ;;
esac
