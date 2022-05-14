#!/usr/bin/env bash

# build
BUILD_DIR="$(pwd)/build"
CONFIGS_DIR="$(pwd)/configs"
SCRIPTS_DIR="$(pwd)/scripts"
BUILD_REPO_DIR="${BUILD_DIR}/repo"
BUILD_ISO_DIR="${BUILD_DIR}/iso"
REPO_NAME="custom"
ARCHISO_PROFILE_DIR="/usr/share/archiso/configs/releng"
ISO_ROOT="${BUILD_ISO_DIR}/airootfs/root"
INSTALLER_DIR="${ISO_ROOT}/installer"
ARCHISO_WORK_DIR="${BUILD_DIR}/archiso-tmp"

# partition
ESP_DIR="/boot/efi"
EFI_MOUNT_DIR="/mnt/boot/efi"
ROOT_MOUNT_DIR="/mnt"

# user
USER_NAME="tom"

# HOST
HOST_NAME="arch"

