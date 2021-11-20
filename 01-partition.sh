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

# Colors to make things look nice
bold=$(tput bold)
normal=$(tput sgr0)

infobox() {
	border_length=$(( ${#1} + 2 ))
	printf "\n${bold}%${border_length}s\n" | tr " " "="
	echo " $1 "
	printf "%${border_length}s${normal}\n\n" | tr " " "="
}
pacman -Sy --noconfirm micro

#loadkeys $KEYMAP
infobox "Setting up clock"
timedatectl set-ntp true 
timedatectl status  
hwclock --systohc --utc

infobox "Setting up partitions"
umount -R /mnt 2> /dev/null || true
cryptsetup luksClose luks 2> /dev/null || true

infobox "Zapping disk" 
wipefs -af "${DISK}" 
sgdisk --zap-all "${DISK}"

infobox "Creating new partition scheme on ${DISK}."
parted "${DISK}" -s mklabel gpt	 

parted "${DISK}" -s mkpart ESP fat32 1MiB 513MiB	
parted "${DISK}" -s set 1 esp on	
parted "${DISK}" -s mkpart Arch 513MiB 100%	

infobox "Formatting the ESP as FAT32."
mkfs.vfat -F 32 $ESP
mkfs.ext4 -L ARCH $ARCH_ROOT

mount $ARCH_ROOT /mnt
mkdir -vp /mnt/boot/efi 
mount -o nodev,nosuid,noexec $ESP /mnt/boot/efi


