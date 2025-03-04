#!/usr/bin/env bash

set -e

ESP_DIR="/boot/efi"
CONFIGS_DIR="/root/configs"
# USER
USER_NAME="tom"
LOGIN_SHELL="/bin/bash"
# HOST
HOST_NAME="arch"

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
    echo $HOST_NAME > /etc/hostname
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
    # delete user if exists
    if id ${USER_NAME} &>/dev/null; then
        userdel -r ${USER_NAME}
    fi
    useradd -m $USER_NAME -s $LOGIN_SHELL
    passwd $USER_NAME

    echo "add group to ${USER_NAME}"
    usermod -aG wheel ${USER_NAME}
    echo "create wheel group"
    echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
}

function setup_grub() {
    # https://wiki.archlinux.org/title/GRUB
    echo "setup grub"
    grub-install --target=x86_64-efi --efi-directory=${ESP_DIR} --bootloader-id=ArchLinux
    grub-mkconfig -o /boot/grub/grub.cfg
}

function setup_pacman() {
    echo "setup pacman"
    cp "${CONFIGS_DIR}/mirrorlist" "/etc/pacman.d/"
    cp "${CONFIGS_DIR}/pacman.conf" "/etc/"
}


function main() {
    setup_user

    # general system setting
    setup_time_locale
    setup_hostname
    setup_pacman

    setup_service

    # set bootloader
    setup_grub
}

main
