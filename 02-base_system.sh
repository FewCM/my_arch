#!/usr/bin/env bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log" >&2)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
#DISK="/dev/nvme0n1"
NEW_USER="fewcm"
HOSTNAME="MyArxh"
LOCALE="en_US.UTF-8"
KEYMAP="us"      
ROOT_PASSWD="1007"
USER_PASSWD="1007"
#ESP="/dev/nvme0n1p1"
#ARCH_ROOT="/dev/nvme0n1p2"
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

# Pacstrap (setting up a base sytem onto the new root).
infobox "Installing the base system"
cp "$DIR"/pacman.conf /etc/

pacstrap /mnt base curl linux-zen linux-zen-headers intel-ucode linux-firmware btrfs-progs grub grub-btrfs efibootmgr snapper \
reflector base-devel zsh git  libxft-bgra firewalld zram-generator mlocate man-db

# Setting hostname.
infobox "Setting hostname."
echo "$HOSTNAME" > /mnt/etc/hostname	 

# Setting up locales.
infobox "Setting up locales.."
echo "$LOCALE UTF-8"  > /mnt/etc/locale.gen	 
echo "LANG=$LOCALE" > /mnt/etc/locale.conf 	
arch-chroot /mnt locale-gen 	

# Setting up keyboard layout.
infobox "Setting up keyboard layout."
echo "KEYMAP=$KEYMAP" > /mnt/etc/vconsole.conf	 

# Setting hosts file.
infobox "Setting hosts file."
cat > /mnt/etc/hosts <<EOF
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain   $HOSTNAME
EOF

# Configuring the system.    
infobox "Configuring timezone"
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Asia/Kuala_Lumpur /etc/localtime  

#infobox "Configuring clock"
arch-chroot /mnt hwclock --systohc 

infobox "adding additional blocklist to /etc/hosts"
curl https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts >> /mnt/etc/hosts 	 

# Generating /etc/fstab.
infobox "Generating a new fstab."
genfstab -U -p /mnt  >> /mnt/etc/fstab 
sed -i 's|,subvolid=258,subvol=/@/.snapshots/1/snapshot,subvol=@/.snapshots/1/snapshott||g' /mnt/etc/fstab 
micro /mnt/etc/fstab 

# Setting up /etc/default/grub
infobox "Configuring /etc/default/grub"
sed -i -e 's/GRUB_DISTRIBUTOR="Arch"/GRUB_DISTRIBUTOR="MyArxh"/g'	/mnt/etc/default/grub 	 
echo "" >> /mnt/etc/default/grub  
echo -e "# Booting with BTRFS subvolume\nGRUB_BTRFS_OVERRIDE_BOOT_PARTITION_DETECTION=true" >> /mnt/etc/default/grub 
sed -i -e 's/GRUB_GFXMODE=auto/GRUB_GFXMODE=2560x1080/g'	/mnt/etc/default/grub 	 
sed -i 's/#GRUB_THEME.*/GRUB_THEME="\/boot\/grub\/themes\/default\/theme.txt"/g' /mnt/etc/default/grub 	 
#sed -i -e 's|GRUB_DISABLE_RECOVERY=true|#GRUB_DISABLE_RECOVERY=true|g' /mnt/etc/default/grub
#sed -i -e 's|GRUB_CMDLINE_LINUX_DEFAULT.*|GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet fbcon=nodefer lsm=landlock,lockdown,yama,apparmor,bpf"|g' /mnt/etc/default/grub

UUID=$(blkid $cryptroot | cut -f2 -d'"')
dd bs=512 count=4 if=/dev/random of=/mnt/cryptkey/.root.key iflag=fullblock &>/dev/null
chmod 000 /mnt/cryptkey/.root.key &>/dev/null
cryptsetup -v luksAddKey /dev/disk/by-partlabel/cryptroot /mnt/cryptkey/.root.key
sed -i "s#quiet#cryptdevice=UUID=$UUID:cryptroot root=$BTRFS lsm=landlock,lockdown,yama,apparmor,bpf cryptkey=rootfs:/cryptkey/.root.key#g" /mnt/etc/default/grub
sed -i -e 's|GRUB_CMDLINE_LINUX_DEFAULT.*|GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID=$UUID:cryptroot root=$BTRFS fbcon=nodefer quiet splash vt.global_cursor_default=0 loglevel=3 rd.systemd.show_status=false rd.udev.log-priority=3 sysrq_always_enabled=1"|g' /mnt/etc/default/grub
sed -i 's/#\(GRUB_ENABLE_CRYPTODISK=y\)/\1/' /mnt/etc/default/grub
sed -i 's#rootflags=subvol=${rootsubvol}##g' /mnt/etc/grub.d/10_linux 
sed -i 's#rootflags=subvol=${rootsubvol}##g' /mnt/etc/grub.d/20_linux_xen

sed -i 's#FILES=()#FILES=(/cryptkey/.root.key)#g' /mnt/etc/mkinitcpio.conf

micro /mnt/etc/default/grub

infobox "Adding new user"
arch-chroot /mnt useradd -m -g users -G wheel,storage,power,network,video,audio,lp -s /bin/bash "$NEW_USER" || error "$LINENO"

infobox "adding new user to sudoers"
echo "%wheel      ALL=(ALL) ALL" >> /mnt/etc/sudoers	  
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/mount" >> /mnt/etc/sudoers	  
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/umount" >> /mnt/etc/sudoers	  
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/extra-x86_64-build" >> /mnt/etc/sudoers	  
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/arch-nspawn" >> /mnt/etc/sudoers	  
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/makechrootpkg" >> /mnt/etc/sudoers	  
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/mkarchroot" >> /mnt/etc/sudoers	  
echo "Defaults insults" >> /mnt/etc/sudoers	  
echo "Defaults pwfeedback" >> /mnt/etc/sudoers	  
echo "Defaults timestamp_timeout=30"   >> /mnt/etc/sudoers	  
echo "Defaults passwd_tries=5"   >> /mnt/etc/sudoers	  
echo "Defaults lecture=never"   >> /mnt/etc/sudoers	  
echo "${NEW_USER} ALL=(ALL) NOPASSWD: /usr/bin/psd-overlay-helper" >> /mnt/etc/sudoers

infobox "Adding user & root passwd"
arch-chroot /mnt /bin/bash << EOF
echo "Setting root password"
echo "root:${ROOT_PASSWD}" | chpasswd

echo "Setting user password"
echo "$NEW_USER:${USER_PASSWD}" | chpasswd
EOF

# Disable su for non-wheel users
bash -c 'cat > /mnt/etc/pam.d/su' <<-'EOF'
#%PAM-1.0
auth		sufficient	pam_rootok.so
# Uncomment the following line to implicitly trust users in the "wheel" group.
#auth		sufficient	pam_wheel.so trust use_uid
# Uncomment the following line to require a user to be in the "wheel" group.
auth		required	pam_wheel.so use_uid
auth		required	pam_unix.so
account		required	pam_unix.so
session		required	pam_unix.so
EOF

# ZRAM configuration
bash -c 'cat > /mnt/etc/systemd/zram-generator.conf' <<-'EOF'
[zram0]
zram-fraction = 1
max-zram-size = 8192
EOF
