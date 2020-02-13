#!/bin/bash

# Automate ArchLinux Install

timedatectl set-ntp true
umount -Rl /mnt
parted --script /dev/sda \
	mklabel gpt \
	mkpart primary fat32 1MiB 261MiB \
	set 1 esp on \
	mkpart primary ext4 261MiB 100%

mkfs.fat -F32 /dev/sda1
mkfs.ext4 -F /dev/sda2

# Mount the filesystem

mount /dev/sda2 /mnt
mkdir /mnt/efi -p
mount /dev/sda1 /mnt/efi

# Installation
pacstrap /mnt base linux linux-firmware git vim

# Settin fstab
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt sed -i 's/#\(fr_FR\.UTF-8\)/\1/' /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "KEYMAP=fr-latin9"
arch-chroot /mnt echo "Devbox" > /etc/hostname
