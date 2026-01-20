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
    "openssh",
    "wl-clipboard",
]

services: [
    "sshd",
    // systemd network
    "systemd-networkd",
    "systemd-resolved",
]

user: {
	name:        "tom"
	login_shell: "/bin/bash"
}

host: {
    name: "noob2"
}
