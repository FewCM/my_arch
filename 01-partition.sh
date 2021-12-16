#!/usr/bin/env bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log" >&2)

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)"
DISK="/dev/nvme1n1"
NEW_USER="fewcm"
HOSTNAME="MyArxh"
LOCALE="en_US.UTF-8"
KEYMAP="us"      
ROOT_PASSWD="1007"
USER_PASSWD="1007"
#ESP="/dev/nvme1n1p1"
#ARCH_ROOT="/dev/nvme1n1p2"
#ARCH_BUILD="/dev/nvme1n1p3"
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
parted "${DISK}" -s mkpart Arch 513MiB 208010MiB
parted "${DISK}" -s mkpart Arch_Build 208011MiB 100%	

ESP="/dev/disk/by-partlabel/ESP"
cryptroot="/dev/disk/by-partlabel/Arch"
arch_build="/dev/disk/by-partlabel/Arch_Build"

infobox "Formatting the ESP as FAT32."
mkfs.vfat -F 32 $ESP
mkfs.ext4 $arch_build  -L Arch_Build

# Creating a LUKS Container for the root partition.
echo "Creating LUKS Container for the root partition."
cryptsetup luksFormat --type luks1 $cryptroot
echo "Opening the newly created LUKS Container."
cryptsetup open $cryptroot cryptroot
BTRFS="/dev/mapper/cryptroot"

# Formatting the LUKS Container as BTRFS.
infobox "Formatting the ROOT Partition as BTRFS."
mkfs.btrfs -L Arch $BTRFS &>/dev/null

infobox "Setting up BTRFS subvolumes"
mount $BTRFS /mnt 
btrfs subvolume create /mnt/@  
btrfs subvolume create /mnt/@/.snapshots  
mkdir -vp /mnt/@/.snapshots/1   
btrfs subvolume create /mnt/@/.snapshots/1/snapshot 
btrfs subvolume set-default "$(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+')" /mnt

cat << EOF >> /mnt/@/.snapshots/1/info.xml
<?xml version="1.0"?>
<snapshot>
  <type>single</type>
  <num>1</num>
  <date>2021-01-01 0:00:00</date>
  <description>First Root Filesystem</description>
  <cleanup>number</cleanup>
</snapshot>
EOF

chmod 600 /mnt/@/.snapshots/1/info.xml 

btrfs subvolume create /mnt/@/boot/ || error "$LINENO"
btrfs subvolume create /mnt/@/home || error "$LINENO"
btrfs subvolume create /mnt/@/root || error "$LINENO"
btrfs subvolume create /mnt/@/var_log || error "$LINENO"
btrfs subvolume create /mnt/@/var_cache || error "$LINENO"
btrfs subvolume create /mnt/@/var_tmp || error "$LINENO"
btrfs subvolume create /mnt/@/var_pkg || error "$LINENO"
btrfs su cr /mnt/@/cryptkey  || error "$LINENO"


chattr +C /mnt/@/boot || error "$LINENO"
chattr +C /mnt/@/var_log || error "$LINENO"
chattr +C /mnt/@/var_pkg || error "$LINENO"
chattr +C /mnt/@/var_cache || error "$LINENO"
chattr +C /mnt/@/var_tmp || error "$LINENO"
chattr +C /mnt/@/cryptkey|| error "$LINENO"

# Mounting the newly created subvolumes.
umount /mnt
infobox "Mounting the newly created subvolumes."
mount -o ssd,noatime,space_cache,compress=zstd:15 $BTRFS /mnt || error "$LINENO"
mount -o $BTRFS_OPTS,nodev,nosuid,noexec,subvol=@/boot $BTRFS /mnt/boot || error "$LINENO"
mount -o $BTRFS_OPTS,nodev,nosuid,subvol=@/root $BTRFS /mnt/root  || error "$LINENO"
mount -o $BTRFS_OPTS,nodev,nosuid,subvol=@/home $BTRFS /mnt/home || error "$LINENO"
mount -o $BTRFS_OPTS,subvol=@/.snapshots $BTRFS /mnt/.snapshots || error "$LINENO"
mount -o $BTRFS_OPTS,nodatacow,nodev,nosuid,noexec,subvol=@/var_log $BTRFS /mnt/var/log || error "$LINENO"
mount -o $BTRFS_OPTS,nodatacow,nodev,nosuid,noexec,subvol=@/var_cache $BTRFS /mnt/var/cache || error "$LINENO"
mount -o $BTRFS_OPTS,nodatacow,nodev,nosuid,noexec,subvol=@/var_pkg $BTRFS /mnt/var/cache/pacman || error "$LINENO"
mount -o $BTRFS_OPTS,nodatacow,nodev,nosuid,subvol=@/var_tmp $BTRFS /mnt/var/tmp || error "$LINENO"
mount -o $BTRFS_OPTS,nodatacow,nodev,nosuid,noexec,subvol=@/cryptkey $BTRFS /mnt/cryptkey


mkdir -vp /mnt/boot/efi   || error "$LINENO"
mount -o nodev,nosuid,noexec $ESP /mnt/boot/efi  || error "$LINENO"

mkdir -vp /mnt/var/lib/archbuild   || error "$LINENO"
mount -o nodev,nosuid $arch_build /mnt/var/lib/archbuild || error "$LINENO"

