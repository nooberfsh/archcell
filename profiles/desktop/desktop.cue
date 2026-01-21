package desktop

import (
    S "github.com/nooberfsh/archcell/server"
)

packages: [
    S.packages,

    // wayland related
    "wl-clipboard",

    // graphic driver
    "mesa",

    // dev core
    "base-devel",
    "pacman-contrib",
    "nushell",

    // kde
    "plasma-meta",
    "sddm",
    "konsole",

    // 提供 phonon-qt6-backend, 被 phonon-qt6 依赖, phonon-qt6 被 plasma-meta 依赖
    "phonon-qt6-vlc",

    // 提供 qt6-multimedia-backend, 被 qt6-multimedia 依赖, qt6-multimedia 被 plasma-meta 依赖
    "qt6-multimedia-ffmpeg",

    // 提供 jack, 被 plasma-meta 依赖
    "pipewire-jack",

    // input method
    "fcitx5",
    "fcitx5-chinese-addons",
    "fcitx5-pinyin-zhwiki",

    // fonts
    "wqy-microhei",

    // 提供 ttf-font, 被 plasma-meta 依赖
    "noto-fonts",

    // 提供 emoji-font, 被 plasma-meta 依赖
    "noto-fonts-emoji",
]

services: [
    "sddm"
]

network: {
	type: "networkmanager" // systemd, networkmanager
}

user: {
	name:        "tom"
	login_shell: "/bin/nu"
}

host: {
	name: "noob1"
}
