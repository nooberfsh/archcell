# archcell
archlinux 打包/安装脚本。

## 制作镜像
```bash
./mkiso.nu
```
运行完成之后，镜像文件会在 build 目录下，名字格式为 `archlinux-<date>-x86_64.iso`

## 安装
进入上述打包好的系统，然后
```bash
cd installer
./install.nu
```