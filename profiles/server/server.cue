package server

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
]

network: {
	type: "systemd" // systemd, networkmanager
	// address: dhcp
	address: {
		address: "10.0.20.199/24"
		gateway: "10.0.20.1"
		dns: "223.6.6.6"
	}
}

user: {
	name:        "tom"
	login_shell: "/bin/bash"
}

host: {
	name: "noob2"
}
