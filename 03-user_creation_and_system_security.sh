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
LUKS_PASSPHRASE="1007"
BTRFS_OPTS="ssd,noatime,space_cache=v2,autodefrag,compress=zstd:15,discard=async,X-mount.mkdir"
ESP="/dev/nvme0n1p1"
ARCH_ROOT="/dev/nvme0n1p2"

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
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman -Syu" >> /mnt/etc/sudoers	  
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/pacman -Syyu --noconfirm" >> /mnt/etc/sudoers	  
echo "%wheel ALL=(ALL) NOPASSWD: /usr/bin/loadkeys" >> /mnt/etc/sudoers	  
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

# Configure AppArmor Parser caching
sed -i 's/#write-cache/write-cache/g' /mnt/etc/apparmor/parser.conf || error "$LINENO"
sed -i 's/#Include \/etc\/apparmor.d/Include \/etc\/apparmor.d/g' /mnt/etc/apparmor/parser.conf || error "$LINENO"

# Enabling CPU Mitigations
#curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/default/grub.d/40_cpu_mitigations.cfg >> /mnt/etc/grub.d/40_cpu_mitigations	 || error "$LINENO"

# Distrusting the CPU
#curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/default/grub.d/40_distrust_cpu.cfg >> /mnt/etc/grub.d/40_distrust_cpu	 || error "$LINENO"

# Enabling IOMMU
#curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/default/grub.d/40_enable_iommu.cfg >> /mnt/etc/grub.d/40_enable_iommu	 || error "$LINENO"

# Setting GRUB configuration file permissions
#chmod 755 /mnt/etc/grub.d/* 	 || error "$LINENO"

# Blacklisting kernel modules
#curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/modprobe.d/30_security-misc.conf >> /mnt/etc/modprobe.d/30_security-misc.conf || error "$LINENO"
#chmod 600 /mnt/etc/modprobe.d/* || error "$LINENO"

# Security kernel settings.
#curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/sysctl.d/30_security-misc.conf >> /mnt/etc/sysctl.d/30_security-misc.conf || error "$LINENO"  
#sed -i 's/kernel.yama.ptrace_scope=2/kernel.yama.ptrace_scope=3/g' /mnt/etc/sysctl.d/30_security-misc.conf || error "$LINENO"
#curl https://raw.githubusercontent.com/Whonix/security-misc/master/etc/sysctl.d/30_silent-kernel-printk.conf >> /mnt/etc/sysctl.d/30_silent-kernel-printk.conf || error "$LINENO"
#chmod 600 /mnt/etc/sysctl.d/* || error "$LINENO"

# IO udev rules
#curl https://gitlab.com/garuda-linux/themes-and-settings/settings/garuda-common-settings/-/raw/master/etc/udev/rules.d/50-sata.rules > /mnt/etc/udev/rules.d/50-sata.rules || error "$LINENO"
#curl https://gitlab.com/garuda-linux/themes-and-settings/settings/garuda-common-settings/-/raw/master/etc/udev/rules.d/60-ioschedulers.rules > /etc/udev/rules.d/60-ioschedulers.rules || error "$LINENO"
#chmod 600 /mnt/etc/udev/rules.d/* || error "$LINENO"

# Remove nullok from system-auth
#sed -i 's/nullok//g' /mnt/etc/pam.d/system-auth || error "$LINENO"

# Disable coredump
#echo "* hard core 0" >> /mnt/etc/security/limits.conf || error "$LINENO"

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
