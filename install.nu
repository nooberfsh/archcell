#!/usr/bin/env nu

const root_mount_dir = "/mnt"
const efi_mount_dir = "/mnt/boot/efi"

def main [] {
    print "install start"

    partition_and_mount
    install_packages
    generate_fstab
    enter_chroot

    print "install success"
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

def install_packages [] {
    print "install packages"
    let packages = load_packages
    pacstrap -C "configs/bootstrap_pacman.conf" /mnt ...$packages
    print "install packages success"
}

def generate_fstab [] {
    print "generate fstab"
    genfstab -U /mnt | save /mnt/etc/fstab --append
    print "generate success"
}

def enter_chroot [] {
    print "enter chroot"
    cp "scripts/bootstrap_chroot.sh" $"($root_mount_dir)/root/"
    let dest = $"($root_mount_dir)/root/configs"
    rm -fr $dest
    cp -r configs $dest
    arch-chroot /mnt "/root/bootstrap_chroot.sh"
    print "exit chroot"
}

def load_packages [] {
    let path = "configs/packages.txt"
    open $path
    | lines
    | str trim
    | filter {|it| ($it != "") and not ($it | str starts-with '#')}
}
