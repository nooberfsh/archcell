package desktop

import (
	S "github.com/nooberfsh/archcell/server"
)

packages: [
	S.packages,

	// dev core
	"base-devel",
	"pacman-contrib",
	"nushell",

	// kde
	{
		name: "plasma-meta"
		deps: [
			// 提供 qt6-multimedia-backend, 被 qt6-multimedia 依赖, qt6-multimedia 被 plasma-meta 依赖
			"qt6-multimedia-ffmpeg",
	        // 提供 jack, 被 ffmpeg 依赖, ffmpeg 被 qt6-multimedia-ffmpeg 依赖
	        "pipewire-jack",
			// 提供 ttf-font, 被 plasma-meta 依赖
			"noto-fonts",
			// 提供 emoji-font, 被 plasma-meta 依赖
			"noto-fonts-emoji",
		]
	},
	"sddm",
	"konsole",

	// input method
	"fcitx5",
	"fcitx5-chinese-addons",
	"fcitx5-pinyin-zhwiki",

	// fonts
	"wqy-microhei",
]

services: [
	"sddm",
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
