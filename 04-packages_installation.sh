#!/usr/bin/env bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log" >&2)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
DISK="/dev/nvme0n1"
NEW_USER="fewcm"
HOSTNAME="MyArxh"
LOCALE="en_US.UTF-8"
KEYMAP="us"      
ROOT_PASSWD="1007"
USER_PASSWD="1007"
ESP="/dev/nvme0n1p1"
ARCH_ROOT="/dev/nvme0n1p2"
BTRFS_OPTS="ssd,noatime,space_cache=v2,autodefrag,compress=zstd:15,discard=async,X-mount.mkdir"
       
# Colors to make things look nice
bold=$(tput bold)
normal=$(tput sgr0)

infobox() {
	border_length=$(( ${#1} + 2 ))
	printf "\n${bold}%${border_length}s\n" | tr " " "="
	echo " $1 "
	printf "%${border_length}s${normal}\n\n" | tr " " "="
}

if [ -d /mnt/home/fewcm/Git ] ; then rm -rf  /mnt/home/fewcm/Git ; fi
arch-chroot /mnt sudo -u fewcm bash -c 'mkdir /home/fewcm/Git' 

cp -rf "$DIR"/dotfiles /mnt/home/fewcm/Git
arch-chroot /mnt sudo -u fewcm bash -c 'git clone https://github.com/FewCM/st.git /home/fewcm/Git/st'
arch-chroot /mnt sudo -u fewcm bash -c 'git clone https://github.com/FewCM/dwm-flexipatch.git /home/fewcm/Git/dwm-flexipatch'
arch-chroot /mnt sudo -u fewcm bash -c 'git clone https://github.com/FewCM/dmenu.git /home/fewcm/Git/dmenu'
#arch-chroot /mnt sudo -u fewcm bash -c 'git clone https://github.com/FewCM/plymouth-themes.git /home/fewcm/Git/plymouth-themes'
#arch-chroot /mnt sudo -u fewcm bash -c 'git clone https://github.com/FewCM/usb-automount.git /home/fewcm/Git/usb-automount'
arch-chroot /mnt chown fewcm:users /home/fewcm/Git

infobox "Running initial setup"
infobox "Copying dotfiles to root directoty"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/{.dmrc,.gitignore,.hushlogin,.Xresources,.xsettingsd,.zshenv} /root/
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/Pictures /root  
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/.config /root 
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/.local /root  

infobox "Copying dotfiles to user directoty"
arch-chroot /mnt sudo -u fewcm bash -c 'cp -rf /home/fewcm/Git/dotfiles/{.dmrc,.gitignore,.hushlogin,.Xresources,.xsettingsd,.zshenv} /home/fewcm/'
arch-chroot /mnt sudo -u fewcm bash -c 'cp -rf /home/fewcm/Git/dotfiles/Pictures /home/fewcm'
arch-chroot /mnt sudo -u fewcm bash -c 'cp -rf /home/fewcm/Git/dotfiles/.config /home/fewcm'
arch-chroot /mnt sudo -u fewcm bash -c 'cp -rf /home/fewcm/Git/dotfiles/.local /home/fewcm'


infobox "Installing extra packages"
cp -f $DIR/pacman.conf /mnt/etc
cp -f /etc/pacman.d/mirrorlist  /mnt/etc/pacman.d
#arch-chroot /mnt sudo -u fewcm bash -c 'sudo pacman -Syyu --noconfirm archlinux-keyring'
#arch-chroot /mnt sudo -u fewcm bash -c 'sudo pacman-key --init'
#arch-chroot /mnt sudo -u fewcm bash -c 'sudo pacman-key --populate archlinux'
arch-chroot /mnt sudo -u fewcm bash -c 'sudo pacman -Syu --noconfirm yay-bin'
arch-chroot /mnt sudo -u fewcm bash -c 'yay -Syu --noconfirm --needed - < /home/fewcm/foreignpkglist.txt'
arch-chroot /mnt sudo -u fewcm bash -c 'yay -Syu --color=auto --needed --noconfirm - < /home/fewcm/pkglist.txt' 

rm -R /mnt/home/fewcm/.gnupg


