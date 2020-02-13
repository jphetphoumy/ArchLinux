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
pacstrap /mnt base linux linux-firmware git vim grub efibootmgr

# Settin fstab
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt sed -i 's/#\(fr_FR\.UTF-8\)/\1/' /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "KEYMAP=fr-latin9" > /etc/vconsole.conf
arch-chroot /mnt echo "Devbox" > /etc/hostname
arch-chroot /mnt echo "127.0.0.1	localhost" >> /etc/hosts
arch-chroot /mnt echo "::1	localhost" >> /etc/hosts
arch-chroot /mnt echo "127.0.1.1	Devbox.localdomain	Devbox" >> /etc/hosts
arch-chroot /mnt echo "root:changeme" | chpasswd
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=efi --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
