package desktop_full

import (
	D "github.com/nooberfsh/archcell/desktop"
)

packages: [
	D.packages,

    // graphic driver
    "mesa",

    // gui
    "dolphin", // 文件浏览器
    "firefox",
    "ark", // kde 解压缩
    "yakuake", // F12 下拉 terminal
    "spectacle", // 截图工具
    "kate", // kde 编辑器
    {
        name: "okular", // kde 文档浏览器
        // 提供 phonon-qt6-backend, 被 phonon-qt6 依赖, phonon-qt6 被 okular 依赖
        deps: ["phonon-qt6-vlc"]
    },
    "qbittorrent",
    "gwenview", // kde 图片浏览器
    "partitionmanager",
    "vlc",
    "lact", // gpu 监控工具

    // dev tool
    "linux-headers",
    "archiso",
    "llvm",
    "git",
    "7zip",
    "tokei",
    "fd",
    "ripgrep",
    "zip",
    "neovim",
    "wl-clipboard", // neovim clipboard tool
    "helix",
    "clang",
    "cmake",
    "ethtool",
    "fio",
    "iperf",
    "iperf3",
    "keyd", // 改键工具
    "nvme-cli",
    "unrar",
    "htop",
    "gnupg",
    // https://wiki.archlinux.org/title/VirtualBox
    "virtualbox-host-modules-arch",
    "gitui",

    // arhlinuxcn
    "archlinuxcn-keyring",
    "yay",
]

services: [
    "sddm",
    "keyd",
]

network: {
	type: "networkmanager" // systemd, networkmanager
}

user: {
	name:        "tom"
	login_shell: "/bin/nu"
}

host: {
	name: "arch"
}
