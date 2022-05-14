#!/usr/bin/env bash

set -e

source "scripts/configs.sh"

function setup_time_locale() {
    echo "setup time and locale"
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
    echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
    locale-gen
    echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

function setup_hostname() {
    echo "setup hostname"
    echo arch > /etc/hostname
}

function setup_service() {
    echo "setup service"

    echo "enable sddm"
    systemctl enable sddm

    echo "enable network"
    systemctl enable NetworkManager
}

function setup_user() {
    echo "setup user"

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

function setup_grub() {
    # https://wiki.archlinux.org/title/GRUB
    echo "setup grub"
    grub-install --target=x86_64-efi --efi-directory=${ESP_DIR} --bootloader-id=GRUB
    grub-mkconfig -o /boot/grub/grub.cfg
}

function main() {
    setup_time_locale
    setup_hostname
    setup_service
    setup_user
    setup_grub
}

main

