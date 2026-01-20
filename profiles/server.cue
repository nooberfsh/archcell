packages: [
    "base",
    "linux",
    "linux-firmware",
    "amd-ucode",
    "intel-ucode",
    "iptables-nft",
    "mkinitcpio",
    "sudo",
    "neovim",
    "man-db",
    "man-pages",
    "nushell",
    "openssh",
    "wl-clipboard",
]

services: [
    "sshd",
    // systemd network
    "systemd-networkd",
    "systemd-resolved",
]
