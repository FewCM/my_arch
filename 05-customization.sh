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

arch-chroot /mnt chsh -s /bin/zsh root  
arch-chroot /mnt chsh -s /bin/zsh fewcm  
arch-chroot /mnt nvidia-xconfig 

arch-chroot /mnt sudo -u fewcm bash -c 'gpg --import /home/fewcm/Git/dotfiles/pubkey.asc'
arch-chroot /mnt sudo -u fewcm bash -c 'echo "5\ny\n" | gpg --command-fd 0 --no-tty --batch --edit-key 941757AAE8D74892 trust'
arch-chroot /mnt sudo -u fewcm bash -c 'find /home/fewcm/.local/share/gnupg -type f -not -path "*#*" -exec chmod 600 {} \;'
arch-chroot /mnt sudo -u fewcm bash -c 'find /home/fewcm/.local/share/gnupg -type d -exec chmod 700 {} \;'

infobox "Copying additional system configuration file"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/grub.d/40_custom /etc/grub.d/  || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/lxdm/lxdm.conf /etc/lxdm/   || error "$LINENO"
#arch-chroot /mnt cp -rf /home/fewcm/Git/plymouth-themes/spin/ /usr/share/plymouth/themes || error "$LINENO"
#arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/plymouth/plymouthd.conf /etc/plymouth/ || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/pulse/default.pa /etc/pulse/  || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/pulse/system.pa /etc/pulse/  || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/snapper/configs/root /etc/snapper/configs || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/snapper/configs/home /etc/snapper/configs || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/tmpfiles.d/tmp.conf /etc/tmpfiles.d || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/udev/rules.d/10-network.rules /etc/udev/rules.d  || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/X11/xorg.conf /etc/X11/  || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/xdg/reflector/reflector.conf /etc/xdg/reflector/reflector.conf  || error "$LINENO"
arch-chroot /mnt cp -rf /home/fewcm/Git/dotfiles/etc/updatedb.conf /etc/  || error "$LINENO"

infobox  "configuring system hooks"
arch-chroot /mnt cp -f /home/fewcm/Git/dotfiles/usr/share/libalpm/hooks/{90-nvidia.hook,99-fewcm-grub.hook,foreignpkglist.hook,pkglist.hook} /usr/share/libalpm/hooks/ || error "$LINENO"
arch-chroot /mnt cp -f /home/fewcm/Git/dotfiles/usr/local/bin/{flexipatch-finalizer.sh,screenrecorder,takeshot,update-grub} /usr/local/bin || error "$LINENO"
arch-chroot /mnt chmod +x /usr/local/bin/{flexipatch-finalizer.sh,screenrecorder,takeshot,update-grub} || error "$LINENO"

# Configuring /etc/mkinitcpio.conf.
infobox "Configuring /etc/mkinitcpio.conf"
sed -i -e 's/MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/g'  /mnt/etc/mkinitcpio.conf
sed -i 's,#COMPRESSION="zstd",COMPRESSION="zstd",g' /mnt/etc/mkinitcpio.conf
sed -i -e 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck grub-btrfs-overlayfs)/g'  /mnt/etc/mkinitcpio.conf
micro /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -P 

infobox "Configuring Grub installation"
echo "GRUB_DISABLE_OS_PROBER=false"  >> /mnt/etc/default/grub
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ARCH
arch-chroot /mnt cp -rf /usr/share/grub/themes/archcraft /boot/grub/themes/default 
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg  
arch-chroot /mnt mkdir -pv /boot/efi/EFI/BOOT 
arch-chroot /mnt cp -rf /boot/efi/EFI/ARCH/grubx64.efi /boot/efi/EFI/BOOT/BOOTx64.efi  
micro /mnt/boot/grub/grub.cfg 

infobox "Snapper Setup"
umount /mnt/.snapshots  
rm -rf /mnt/.snapshots  
arch-chroot /mnt snapper --no-dbus -c root create-config /
arch-chroot /mnt snapper --no-dbus -c home create-config /home  
arch-chroot /mnt btrfs subvolume delete /.snapshots  
arch-chroot /mnt mkdir -pv /.snapshots  
arch-chroot /mnt chmod 750 /.snapshots  
arch-chroot /mnt chmod a+rx /.snapshots   
arch-chroot /mnt chown :wheel /.snapshots   
arch-chroot /mnt mount -a 

infobox "enabling systemd.service"
systemctl enable snapper-timeline.timer --root=/mnt || error "$LINENO"
systemctl enable snapper-cleanup.timer  --root=/mnt|| error "$LINENO"
systemctl enable snapper-boot.timer  --root=/mnt|| error "$LINENO"
systemctl enable grub-btrfs.path    --root=/mnt|| error "$LINENO"
systemctl enable btrfs-scrub@home.timer  --root=/mnt || error "$LINENO" 
systemctl enable btrfs-scrub@-.timer --root=/mnt || error "$LINENO" 
#systemctl enable lxdm-plymouth.service  	--root=/mnt || error "$LINENO"
systemctl enable lxdm.service  	--root=/mnt || error "$LINENO"
systemctl enable NetworkManager.service --root=/mnt	 || error "$LINENO"
systemctl enable systemd-resolved.service --root=/mnt	 || error "$LINENO"
systemctl enable reflector.timer --root=/mnt || error "$LINENO"
systemctl disable reflector.service --root=/mnt || error "$LINENO"
systemctl enable pkgfile-update.timer  --root=/mnt || error "$LINENO"
systemctl enable betterlockscreen@fewcm.service --root=/mnt  || error "$LINENO"
systemctl enable fstrim.timer --root=/mnt &>/dev/null  || error "$LINENO"
systemctl enable apparmor --root=/mnt &>/dev/null  || error "$LINENO"

infobox  "building st"
arch-chroot /mnt sudo -u fewcm bash -c 'mkdir -pv /home/fewcm/suckless'
arch-chroot /mnt sudo -u fewcm bash -c 'cp -rf /home/fewcm/Git/{st,dwm-flexipatch,dmenu} /home/fewcm/suckless'
arch-chroot /mnt sudo -u fewcm bash -c 'cd /home/fewcm/suckless/st ; make && sudo make clean install ; /home/fewcm/.local/bin/flexipatch-finalizer.sh -o . -d . -r --debug'

infobox  "building dwm"
arch-chroot /mnt sudo -u fewcm bash -c 'cd /home/fewcm/suckless/dwm-flexipatch ; make && sudo make clean install ; /home/fewcm/.local/bin/flexipatch-finalizer.sh -o . -d . -r --debug'

infobox  "building dmenu"
arch-chroot /mnt sudo -u fewcm bash -c 'cd /home/fewcm/suckless/dmenu ; make && sudo make clean install ; /home/fewcm/.local/bin/flexipatch-finalizer.sh -o . -d . -r --debug'

infobox "Hide Unnecessary Apps"
adir="/mnt/usr/share/applications"
apps=(avahi-discover.desktop bssh.desktop bvnc.desktop echomixer.desktop \
	envy24control.desktop exo-preferred-applications.desktop feh.desktop \
	hdajackretask.desktop hdspconf.desktop hdspmixer.desktop hwmixvolume.desktop lftp.desktop \
	libfm-pref-apps.desktop lxshortcut.desktop lstopo.desktop \
	networkmanager_dmenu.desktop nm-connection-editor.desktop pcmanfm-desktop-pref.desktop \
	qv4l2.desktop qvidcap.desktop stoken-gui.desktop stoken-gui-small.desktop thunar-bulk-rename.desktop \
	thunar-settings.desktop thunar-volman-settings.desktop yad-icon-browser.desktop \
	xfce4-about.desktop xfce4-accessibility-settings.desktop xfce4-color-settings.desktop xfce4-file-manager.desktop \
	xfce4-mail-reader.desktop xfce4-mime-settings.desktop xfce4-notifyd-config.desktop xfce4-power-manager-settings.desktop \
	xfce4-settings-editor.desktop xfce4-terminal-emulator.desktop xfce4-web-browser.desktop xfce-display-settings.desktop \
	xfce-keyboard-settings.desktop xfce-mouse-settings.desktop xfce-settings-manager.desktop xfce-ui-settings.desktop \
	avahi-discover.desktop blueberry.desktop blueman-adapters.desktop blueman-manager.desktop bluetooth-sendto.desktop \
	com.github.pulseaudio-equalizer-ladspa.Equalizer.desktop compton.desktop czkawka-gui.desktop \
	echomixer.desktop envy24control.desktop gkbd-keyboard-display.desktop hdajackretask.desktop hdspconf.desktop \
	hdspmixer.desktop hwmixvolume.desktop ibus-setup-bopomofo.desktop ibus-setup-libbopomofo.desktop \
	ibus-setup-libpinyin.desktop ibus-setup-pinyin.desktop org.freedesktop.IBus.Panel.Emojier.desktop \
	org.freedesktop.IBus.Panel.Extension.Gtk3.desktop org.freedesktop.IBus.Setup.desktop qv4l2.desktop \
	qvidcap.desktop)

for app in "${apps[@]}"; do
	if [[ -e "$adir/$app" ]]; then
		sed -i '$s/$/\nNoDisplay=true/' "$adir/$app"
	fi
done

#gh extension install jongio/gh-setup-git-credential-helper
#gh setup-git-credential-helper

echo "Done!"
