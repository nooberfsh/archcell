#!/usr/bin/env bash

set -e

# user info
USER_NAME="tom"
ESP_DIR="/boot/efi"
PACKAGES_DESKTOP=(plasma sddm konsole ark okular spectacle dolphin)

function config() {
    echo "set password for root:"
    passwd

    # https://wiki.archlinux.org/title/GRUB
    echo "install grub"
    grub-install --target=x86_64-efi --efi-directory=${ESP_DIR} --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg

    echo "enable network"
    systemctl enable NetworkManager

    echo "create user: ${USER_NAME}"
    useradd -m $USER_NAME
    passwd $USER_NAME
    echo "add group to ${USER_NAME}"
    usermod -aG wheel
    echo "create wheel group"
    echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
}

function desktop() {
    pacman -S ${PACKAGES_DESKTOP[@]}
    systemctl enable sddm
}

function main() {
    echo "begin to config"
    config

    echo "begin to setup desktop..."
    desktop
}

main

