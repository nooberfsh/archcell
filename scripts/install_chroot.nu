#!/usr/bin/env nu

const hostname = "arch"
const user_name = "tom"
const configs_dir = "/root/configs"
const esp_dir = "/boot/efi"
const login_shell = "/bin/bash"

def main [] {
    print "bootstrap configuration"
       
    setup_user
    setup_time_zone_and_locale
    setup_hostname
    setup_pacman
    setup_service
    setup_grub
    
    print "bootstrap configuration success"
}

def setup_user [] {
    print "setup user"

    print $"create user: ($user_name)"
    if (sys users | where name == $user_name | is-not-empty) {
        userdel -r $user_name
    }
    useradd -m $user_name -s $login_shell

    print "create wheel group"
    "%wheel ALL=(ALL) ALL" | save /etc/sudoers.d/wheel -f
    print $"append ($user_name) to group: wheel"
    usermod -aG wheel $user_name

    print "set password:"
    let password = input
    $"($password)" | passwd $user_name -s
    $"($password)" | passwd root -s

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

def setup_hostname [] {
    print "setup hostname"
    $hostname | save /etc/hostname
    print "setup hostname success"
}

def setup_pacman [] {
    print "setup pacman"
    cp $"($configs_dir)/mirrorlist" "/etc/pacman.d/"
    cp $"($configs_dir)/pacman.conf" "/etc/"
    print "setup pacman success"
}

def setup_service [] {
    print "setup service"
    
    print "enable sddm"
    systemctl enable sddm

    print "enable network"
    systemctl enable NetworkManager
    
    print "setup service success"
}

def setup_grub [] {
    # https://wiki.archlinux.org/title/GRUB
    print "setup grub"
    grub-install --target=x86_64-efi $"--efi-directory=($esp_dir)" --bootloader-id=ArchLinux
    grub-mkconfig -o /boot/grub/grub.cfg
    print "setup grub success"
}
