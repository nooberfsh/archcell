# archcell
archlinux 打包/安装脚本。

## Prerequisite
- archlinux: 目前只支持在 archlinux 打包
- nushell: 打包脚本已经用 nushell 重写.
- archiso: 基础打包工具

## 制作镜像
```nu
./mkiso.nu
```
运行完成之后，镜像文件会在 `build/<profile>` 目录下，名字格式为 `archlinux-<date>-x86_64.iso`

### Profile
制作镜像的时候会让用户选择某个 profile, profile 代表一组 package 和一组 service. 目前包含以下 profiles:
- server: 不包含桌面环境,趋向于最小化安装.
- desktop: 基础桌面版本,只包含必要的包,趋向于最小化安装.
- desktop_extra: 这个 profile 接近我日常使用的配置,趋向于最大化安装.

所有 profile 可以在 `profiles` 目录下找到.另外 `profiles` 下面有一个 `network` 目录, 该目前主要
是让用户选择基础网络工具,目前包含:
- systemd: 使用 systemd 自带的网络配置工具.
- networkmanager

选择不同的网络配置, 会影响相关的服务和包,具体的信息可以看目录下面同名的文件, 里面配置的信息会追加到
上面选择的 profile 中.

### archconfig
如果 `HOME` 目录存在 `archconfig` 目录, `mkiso.nu` 会自动把该目录打包到 iso 中, 安装的时候会把
这个目录放置到相应的地方.

通过这个功能我们可以把常用的配置(比如 dotfiles) 打包进去,在安装完系统后可以快速让系统配置成我们想要的样子.


## 安装
进入上述打包好的系统，然后
```bash
cd installer
./install.nu
```
