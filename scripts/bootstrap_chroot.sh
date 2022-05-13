#!/usr/bin/env bash

set -e

source "scripts/configs.sh"

function user() {
    echo "config user"

    echo "set password for root:"
    passwd

    echo "create user: ${USER_NAME}"
    useradd -m $USER_NAME
    passwd $USER_NAME
    echo "add group to ${USER_NAME}"
    usermod -aG wheel
    echo "create wheel group"
    echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
}

function grub() {
    # https://wiki.archlinux.org/title/GRUB
    echo "install grub"
    grub-install --target=x86_64-efi --efi-directory=${ESP_DIR} --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
}

function setup_service() {
    echo "setup service"

    echo "enable sddm"
    systemctl enable sddm

    echo "enable network"
    systemctl enable NetworkManager
}

function main() {
    user
    grub
    setup_service
}

main

