#!/bin/bash

# Automate ArchLinux Install

timedatectl set-ntp true
hostname=$(dialog --stdout --inputbox "Set hostname Hostname:" 0 0) || exit 1
: ${hostname:?"hostname cannot be empty"}
devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|loop|rpmb" | tac)
device=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1
parted --script "${device}" -- mklabel gpt \
	mkpart ESP fat32 1Mib 129MiB \
	set 1 boot on \
	mkpart primary ext4 129MiB 100%

part_boot="${device}1"
part_root="${device}2"

mkfs.fat -F32 ${part_boot}
mkfs.ext4 ${part_root}
mount ${part_root} /mnt
mkdir /mnt/efi
mount ${part_boot} /mnt/boot
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
