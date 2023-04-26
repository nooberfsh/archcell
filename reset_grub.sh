#!/usr/bin/env bash

set -e

source "scripts/common.sh"
source "scripts/configs.sh"

function reset_init() {
    echo "reset init"

    # https://stackoverflow.com/questions/1378331/bash-script-umount-a-device-but-dont-fail-if-its-not-mounted
    echo "try un mount"
    umount ${EFI_MOUNT_DIR} || /bin/true
    umount ${ROOT_MOUNT_DIR} || /bin/true
}

# mount efi and root partition
function mount_partitions() {
    echo "begin to mount partitions"

    local efi_part=$1
    local root_part=$2

    mount $root_part $ROOT_MOUNT_DIR
    mount --mkdir $efi_part $EFI_MOUNT_DIR
}

function enter_chroot() {
    echo "enter arch chroot"
    local f="setup_grub_chroot.sh"
    cp "${SCRIPTS_DIR}/${f}" "${ROOT_MOUNT_DIR}/root/${f}"

    arch-chroot /mnt "/root/${f}"
}

function main() {
    if [[ $# -ne 2 ]]; then
        echo "error: expect 2 arguments. Usage: ./reset_grub.sh <efi_partition> <root_partition>" >&2; exit 1
    fi

    reset_init
    mount_partitions "$@"
    enter_chroot

    echo "reset grub success!"
}

main "$@"
