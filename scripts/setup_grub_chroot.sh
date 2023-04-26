#!/usr/bin/env bash

ESP_DIR="/boot/efi"

function setup_grub() {
    # https://wiki.archlinux.org/title/GRUB
    echo "setup grub"
    grub-install --target=x86_64-efi --efi-directory=${ESP_DIR} --bootloader-id=ArchLinux
    grub-mkconfig -o /boot/grub/grub.cfg
}

setup_grub
