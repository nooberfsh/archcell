#!/usr/bin/env nu

const root_mount_dir = "/mnt"
const efi_mount_dir = "/mnt/boot"

def main [] {
    print "install start"

    let profile = open "profile.nuon"

    partition_and_mount
    install_packages $profile.packages
    generate_fstab
    enter_chroot
    dirty $profile

    print "install success"
}

def "main reset_bootloader" [] {
    print "reset bootloader start"

    let disks = (
        lsblk -ap -o "NAME,MOUNTPOINT,MODEL,FSTYPE,PARTTYPENAME" -J
        | from json
        | get blockdevices
    )
    let disks = (
        $disks
        | where ($it.children? | length) == 2 and ($it.children | get 0.parttypename) == 'EFI System'
    )
    if ($disks | is-empty) {
        error make {msg: "can not find disk with EFI partition"}
    }

    if ($disks | length) != 1 {
        error make {msg: "find multiple disks with EFI partition"}
    }

    let disk = $disks | first
    print $disk

    let efi_partition = $disk.children.0
    let root_partition = $disk.children.1
    print $efi_partition
    print $root_partition

    if $root_partition.mountpoint == null {
        mount $root_partition.name $root_mount_dir
    } else {
        print $"found root partition has already mounted at ($root_partition.mountpoint)"
    }

    if $efi_partition.mountpoint == null {
        mount $efi_partition.name $efi_mount_dir
    } else {
        print $"found efi partition has already mounted at ($efi_partition.mountpoint)"
    }

    enter_chroot "reset_bootloader"

    print "reset bootloader success"
}

# let user choose a disk to partition
# the disk will be partitioned into two parts: esp and the main linux filesystem
# esp will be 512M large where the rest disk room will be left to the main linux filesystem
def partition_and_mount [] {
    print "partition and mount"
    let disks = (
        lsblk -p -b -o "NAME,TYPE,MODEL,SERIAL,SIZE" -J
        | from json
        | get blockdevices
        | where type == 'disk'
    )

    print "choose which disk to partition:"
    let disk = $disks | input list
    print $disk

    # we create two partition here, one for EFI and another one for Linux
    # Tip: after partitioning, you can use `sfdisk -d <disk>` to check if the result is desired.
    # Note: the last partition does not use the last few sectors due to the
    # alignment requirements, see https://wiki.archlinux.org/title/fdisk#First_and_last_sector
    parted $disk.name mklabel gpt
    # align to 1MiB, the first 1MiB is for gpt partition table, the rest 512MiB is for efi
    parted $disk.name mkpart primary 1MiB 513MiB
    parted $disk.name set 1 esp on
    let disk_size = $disk.size / 1024 / 1024 | into int
    parted $disk.name mkpart primary 513MiB $"($disk_size)MiB"

    let partitions = (
        lsblk -p -J $disk.name
        | from json
        | get blockdevices.children
        | first
        | sort-by name
    )

    let efi_partition = $partitions | get 0
    let root_partition = $partitions | get 1
    print "created partitions:"
    print $"efi partition: ($efi_partition), root partition: ($root_partition)"

    mkfs.ext4 $root_partition.name
    mount $root_partition.name $root_mount_dir
    print "mount root partition success"

    mkfs.fat -F 32 $efi_partition.name
    mount --mkdir $efi_partition.name $efi_mount_dir
    print "mount efi partition success"

    print "partition and mount success"
}

def install_packages [packages] {
    print "install packages"
    pacstrap -C "configs/bootstrap_pacman.conf" /mnt ...$packages
    print "install packages success"
}

def generate_fstab [] {
    print "generate fstab"
    genfstab -U /mnt | save /mnt/etc/fstab --append
    print "generate success"
}

def enter_chroot [
    cmd: string = ""
] {
    print "enter chroot"
    let f = "install_chroot.nu"
    cp $"scripts/($f)" $"($root_mount_dir)/root/"
    cp "profile.nuon" $"($root_mount_dir)/root/"
    let archconfig = "archconfig.tar.gz"
    if ($archconfig | path exists) {
        cp $archconfig $"($root_mount_dir)/root/"
    }
    let dest = $"($root_mount_dir)/root/configs"
    rm -fr $dest
    cp -r configs $dest
    arch-chroot /mnt $"/root/($f)" $cmd
    print "exit chroot"
}

def dirty [profile] {
    print "handle dirty stuff"
    for service in $profile.services {
        # https://wiki.archlinux.org/title/Systemd-resolved#DNS
        if $service == "systemd-resolved" {
            print "handing /etc/resolv.conf"
            ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
        }
    }

    print "handle dirty stuff success"
}
