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
