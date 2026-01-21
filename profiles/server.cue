packages: [
	// base 依赖 iproute2, iproute2 依赖 libxtables.so=12-64, 指定 iptables-nft 提供
    {name: "base", deps: ["iptables-nft"]},
	// linux 依赖 initramfs, 指定 mkinitcpio 提供.
    {name: "linux", deps: ["mkinitcpio"]},
    "linux-firmware",
    "amd-ucode",
    "intel-ucode",
    "sudo",
    "neovim",
    "man-db",
    "man-pages",
    "openssh",
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
