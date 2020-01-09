#!/bin/bash

# Automate ArchLinux Install

timedatectl set-ntp true

# Try to umount /mnt if already mounted
umount -R /mnt

# Get Hostname set by user
hostname=$(dialog --stdout --inputbox "Set hostname Hostname:" 0 0) || exit 1
: ${hostname:?"hostname cannot be empty"}

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|loop|rpmb" | tac)
device=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1

# Partition disk
parted --script ${device} mklabel gpt \
	mkpart primary fat32 1Mib 261MiB \
	set 1 esp on \
	mkpart primary ext4 261MiB 100%

# Define partition
part_efi="${device}1"
part_root="${device}2"

mkfs.fat -F32 ${part_efi}
mkfs.ext4 ${part_root}

mount ${part_root} /mnt
mkdir /mnt/efi
mount ${part_efi} /mnt/efi

pacstrap /mnt base linux linux-firmware git ansible efibootmgr grub wpa_supplicant dhcpcd
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
arch-chroot /mnt echo KEYMAP=fr-latin9 > /etc/vconsole.conf
arch-chroot /mnt echo $hostname > /etc/hostname
arch-chroot /mnt echo "127.0.1.1 ${hostname}.localdomain ${hostname}" >> /etc/hosts
arch-chroot /mnt echo "root:changeme" | chpasswd
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
