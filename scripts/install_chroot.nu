#!/usr/bin/env nu

const configs_dir = "/root/configs"
const esp_dir = "/boot"
const login_shell = "/bin/nu"

def main [] {
    print "bootstrap configuration"

    let profile = open "/root/profile.nuon"

    setup_user $profile
    setup_time_zone_and_locale
    setup_hostname $profile
    setup_pacman
    setup_service $profile
    setup_bootloader

    print "bootstrap configuration success"
}

def "main reset_bootloader" [] {
    setup_bootloader
}

def "main reset_systemd_boot_config" [] {
    setup_systemd_boot_config $esp_dir
}

def setup_user [profile] {
    print "setup user"
    
    print "set username:"
    let username = $profile.user.name

    print $"create user: ($username)"
    if (sys users | where name == $username | is-not-empty) {
        userdel -r $username
    }
    useradd -m $username -s $login_shell

    print "create wheel group"
    "%wheel ALL=(ALL) ALL" | save /etc/sudoers.d/wheel -f
    print $"append ($username) to group: wheel"
    usermod -aG wheel $username

    print "set password:"
    let password = input -s '>>'
    $"($password)" | passwd $username -s
    $"($password)" | passwd root -s

    let archconfig = "/root/archconfig.tar.gz"
    if ($archconfig | path exists) {
        let user_home = $"/home/($username)"
        do {
          cd $user_home
          tar -xzf $archconfig
          chown -hR $"($username):($username)" "archconfig"
        }
    }

    print "setup user success"
}

def setup_time_zone_and_locale [] {
    print "setup time zone and locale"
    ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

    "en_US.UTF-8 UTF-8" | save /etc/locale.gen --append
    "zh_CN.UTF-8 UTF-8" | save /etc/locale.gen --append
    locale-gen
    "LANG=en_US.UTF-8" | save /etc/locale.conf
    
    print "setup time zone and locale success"
}

def setup_hostname [profile] {
    print "setup hostname"
    print "set hostname:"
    let hostname = $profile.host.name
    $hostname | save /etc/hostname
    print "setup hostname success"
}

def setup_pacman [] {
    print "setup pacman"
    cp $"($configs_dir)/mirrorlist" "/etc/pacman.d/"
    cp $"($configs_dir)/pacman.conf" "/etc/"

    pacman-key --init
    pacman-key --populate
    print "setup pacman success"
}

def setup_service [profile] {
    print "setup service"

    for service in $profile.services {
        print $"enable ($service)"
        systemctl enable $service
    }

    print "setup service success"
}

def setup_bootloader [] {
    print "steup systemd-boot"

    bootctl install
    setup_systemd_boot_config $esp_dir

    print "setup systemd-boot success"
}

# https://wiki.archlinux.org/title/Systemd-boot#Configuration
def setup_systemd_boot_config [esp] {
    print "generate systemd boot config"
    let root_part = findmnt -no SOURCE /
    let root_part_uuid = blkid $root_part -o json | from json | get uuid

    if not ($"($esp)/loader" | path exists) {
        mkdir $"($esp)/loader"
    }

    if not ($"($esp)/loader/entries" | path exists) {
        mkdir $"($esp)/loader/entries"
    }
    
    let loader = "
default  arch.conf
timeout  4
console-mode max
editor   no
"

    let entry = $"
title   Arch Linux
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=($root_part_uuid) rw        
"

    $loader | save -f $"($esp)/loader/loader.conf"
    $entry | save -f $"($esp)/loader/entries/arch.conf"
    
    print "generate systemd boot config success"
}
