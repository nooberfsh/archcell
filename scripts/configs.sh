#!/usr/bin/env bash

# build
BUILD_DIR="$(pwd)/build"
CONFIGS_DIR="$(pwd)/configs"
BUILD_REPO_DIR="${BUILD_DIR}/repo"
BUILD_ISO_DIR="${BUILD_DIR}/iso"
REPO_NAME="custom"
ARCHISO_PROFILE_DIR="/usr/share/archiso/configs/releng"
ISO_ROOT="${BUILD_ISO_DIR}/airootfs/root"
INSTALLER_DIR="${ISO_ROOT}/installer"

# partition
ESP_DIR="/boot/efi"
EFI_MOUNT_DIR="/mnt/boot/efi"
ROOT_MOUNT_DIR="/mnt"

# user
USER_NAME="tom"
