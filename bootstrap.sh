#!/bin/bash

# Automate ArchLinux Install

hostname=$(dialog --stdout --inputbox "Set hostname Hostname:" 0 0) || exit 1
: ${hostname:?"hostname cannot be empty"}
devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|loop|rpmb" | tac)
device=$(dialog --stdout --menu "Select installation disk" 0 0 0 ${devicelist}) || exit 1
parted --script "${device}" -- mklabel gpt \
	mkpart ESP fat32 1Mib 129MiB \
	set 1 boot on \
	mkpart primary ext4 2177MiB 100%
