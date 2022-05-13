#!/usr/bin/env bash

set -e

###################################################
# config begin

# partition spec
ESP_DIR="/boot/efi"
EFI_MOUNT_DIR="/mnt/boot/efi"
ROOT_MOUNT_DIR="/mnt"
# pacman
PACMAN_MIRRORS=(
"Server=https://mirrors.sjtug.sjtu.edu.cn/archlinux/\$repo/os/\$arch"
"Server=https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
)
PACMAN_PARALLEL=4
PACKAGES=(base linux linux-firmware networkmanager grub efibootmgr sudo vi vim git)


# config end
###################################################


function partition_and_mount() {
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
        echo "no disk found, abort"; exit -1
    else
        echo "found ${disknum} disks"
        for i in ${!disks[@]}; do
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

function install() {
    ## setup pacman
    # TODO: specify parallel downloads
    local mirror_file="/etc/pacman.d/mirrorlist"
    echo > $mirror_file
    for m in ${PACMAN_MIRRORS[@]}; do
        echo $m >> $mirror_file
    done

    ## install kernel and other packages
    pacstrap /mnt ${PACKAGES[@]}
}

function generate_fstab() {
    genfstab -U /mnt >> /mnt/etc/fstab
}

function enter_chroot() {
    arch-chroot /mnt /bootstrap_chroot.sh
}

function main() {
    echo "begin to partiton and mount..."
    partition_and_mount

    echo "begin to generate fstab..."
    generate_fstab

    echo "enter chroot..."
    enter_chroot
}

main

