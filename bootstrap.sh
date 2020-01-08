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
wipefs ${part_boot}
wipefs ${part_root}

mkfs.fat -F32 ${part_boot}
mkfs.ext4 ${part_root}
mount ${part_root} /mnt
mkdir /mnt/boot/efi -p 
mount -t vfat ${part_boot} /mnt/boot/efi
mkdir /mnt/boot/efi/EFI -p 
grub-install --target=x86_64-efi --boot-directory=/mnt/boot --efi-directory=/mnt/boot/efi --bootloader-id=ArchLinux --recheck
pacstrap /mnt base
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt pacman -S grub efibootmgr git ansible vim --noconfirm
arch-chroot /mnt ln -sf /usr/share/zoneinfo/Europe/Paris /etc/localtime
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "LANG=fr_FR.UTF-8" > /etc/locale.conf
arch-chroot /mnt echo KEYMAP=fr-latin9 > /etc/vconsole.conf
arch-chroot /mnt echo $hostname > /etc/hostname
arch-chroot /mnt echo "127.0.1.1 ${hostname}.localdomain ${hostname}" >> /etc/hosts
arch-chroot /mnt echo "root:changeme" | chpasswd
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
