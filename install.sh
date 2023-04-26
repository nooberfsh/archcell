#!/usr/bin/env bash

set -e

source "scripts/common.sh"
source "scripts/configs.sh"

function install_init() {
    echo "init"

    # https://wiki.archlinux.org/title/archiso#Adjusting_the_size_of_root_partition_on_the_fly
    echo "adjust the size of the root partition"
    mount -o remount,size=2G /run/archiso/cowspace

    # https://stackoverflow.com/questions/1378331/bash-script-umount-a-device-but-dont-fail-if-its-not-mounted
    echo "try un mount"
    umount ${EFI_MOUNT_DIR} || /bin/true
    umount ${ROOT_MOUNT_DIR} || /bin/true
}

# let user choose a disk to partition
# the disk will be partitioned into two parts: esp and the main linux filesystem
# esp will be 512M large where the rest disk room will be left to the main linux filesystem
function partition_and_mount() {
    echo "begin to partion disk and mount them"

    ## get all disks
    local disks=()

    # split by line
    # https://stackoverflow.com/a/5257398
    IFS=$'\n'
    local blocks=($(lsblk -lp))
    unset IFS

    for block in "${blocks[@]}"; do
        if [[ $block =~ "disk" ]]; then
            local parts=($block)
            disks+=(${parts[0]})
        fi
    done

    ## let user chose which disk to partition
    local disknum=${#disks[@]}
    local diskidx=0
    if [[ $disknum == 0 ]]; then
        echo "no disk found, abort"; exit 1
    else
        echo "found ${disknum} disks"
        for i in "${!disks[@]}"; do
            echo "${i}: ${disks[$i]}"
        done
    fi

    read -p "choose which disk to partition: " diskidx
    re='^[0-9]+$'
    if [[ ! ($diskidx =~ $re) || $diskidx -ge ${disknum} ]] ; then
        echo "error: invalid number: ${diskidx}" >&2; exit 1
    fi

    ## begin to partition
    local diskname=${disks[$diskidx]}
    echo "begin to partition: $diskname"

    # we create two partition here, one for EFI and another one for Linux
    # Tip: after partitioning, you can use `sfdisk -d <disk>` to check if the result is desired.
    # Note: the last partition does not use the last few sectors due to the
    # alignment requirements, see https://wiki.archlinux.org/title/fdisk#First_and_last_sector

    # partitioning with fdisk: https://stackpointer.io/unix/linux-script-to-partition-disk/632/
    sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << FDISK_CMDS  | fdisk $diskname
g       # create new GPT partition
n       # add new partition
1       # partition number
        # default - first sector
+512MiB # partition size
n       # add new partition
2       # partition number
        # default - first sector
        # default - last sector
t       # change partition type
1       # partition number
1       # EFI System
t       # change partition type
2       # partition number
20      # Linux filesystem
w       # write partition table and exit
FDISK_CMDS

    ## mount

    # get all partitions 
    local partitions=()

    # split by line
    # https://stackoverflow.com/a/5257398
    IFS=$'\n'
    local blocks=($(lsblk -lp ${diskname}))
    unset IFS

    for block in "${blocks[@]}"; do
        if [[ $block =~ "part" ]]; then
            local parts=($block)
            partitions+=(${parts[0]})
        fi
    done

    mkfs.ext4 ${partitions[1]}
    mount ${partitions[1]} $ROOT_MOUNT_DIR

    mkfs.fat -F 32 ${partitions[0]}
    mount --mkdir ${partitions[0]} $EFI_MOUNT_DIR
}

# install all packages from local repo
function install_packages() {
    echo "begin to install packages"

    echo "load packages..."
    local packages=()
    local packages_foreign=()
    load_packages "${CONFIGS_DIR}/packages.txt" packages
    load_packages "${CONFIGS_DIR}/packages_foreign.txt" packages_foreign

    local pacman_path="${CONFIGS_DIR}/bootstrap_pacman.conf"
    pacstrap -C ${pacman_path} /mnt "${packages[@]}"
    pacstrap -C ${pacman_path} /mnt "${packages_foreign[@]}"
}

function generate_fstab() {
    echo "generating fstab"
    genfstab -U /mnt >> /mnt/etc/fstab
}

function enter_chroot() {
    echo "enter arch chroot"
    local f="bootstrap_chroot.sh"
    cp "${SCRIPTS_DIR}/${f}" "${ROOT_MOUNT_DIR}/root/${f}"

    local target="${ROOT_MOUNT_DIR}/root/configs"
    rm -fr $target
    cp -r "${CONFIGS_DIR}" $target

    echo "try unmount ${DEV_MOUNT_DIR}"
    umount ${DEV_MOUNT_DIR} || /bin/true
    arch-chroot /mnt "/root/${f}"
}

function main() {
    install_init
    partition_and_mount
    install_packages
    generate_fstab
    enter_chroot

    echo "install success!"
}

main

