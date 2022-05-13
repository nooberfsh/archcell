#!/usr/bin/env bash

set -e

source "scripts/common.sh"

BUILD_DIR="$(pwd)/build"
CONFIGS_DIR="$(pwd)/configs"
BUILD_REPO_DIR="${BUILD_DIR}/repo"
BUILD_ISO_DIR="${BUILD_DIR}/iso"
REPO_NAME="custom"
ARCHISO_PROFILE_DIR="/usr/share/archiso/configs/releng"
ISO_ROOT="${BUILD_ISO_DIR}/airootfs/root"
INSTALLER_DIR="${ISO_ROOT}/installer"

function init() {
    echo "init"

    echo "create build dir: ${BUILD_DIR}"
    mkdir -p $BUILD_DIR

    echo "create repo dir: ${BUILD_REPO_DIR}"
    mkdir -p $BUILD_REPO_DIR

    echo "create iso dir: ${BUILD_ISO_DIR}"
    mkdir -p $BUILD_ISO_DIR
}

# build a local repo, it can be used by archiso and the installation process
function build_local_repo() {
    echo "begin to build local repo"

    echo "load packages..."
    load_packages "${CONFIGS_DIR}/packages.txt"
    load_packages "${ARCHISO_PROFILE_DIR}/packages.x86_64"

    # https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Installing_packages_from_a_CD/DVD_or_USB_stick
    echo "downloading packages "
    sudo pacman -Syw --cachedir ${BUILD_REPO_DIR} --dbpath ${BUILD_REPO_DIR} ${PACKAGES[@]}
    local suffixes=( xz zst )
    for p in ${suffixes[@]}; do
        repo-add "${BUILD_REPO_DIR}/${REPO_NAME}.db.tar.gz" ${BUILD_REPO_DIR}/*.pkg.tar.${p}
    done
}

# build a custom iso
# all packages needed to build iso will be fetched from the local repo
# the local repo will be copied to `/root` for bootstrap in the offline mode
# the project will be copied to `/root`
function build_custom_iso() {
    echo "begin to build custom iso"

    # https://wiki.archlinux.org/title/Archiso#Installation
    cp -a ${ARCHISO_PROFILE_DIR}/. ${BUILD_ISO_DIR}

    echo "modify archiso pacman.conf"
    local p="${BUILD_ISO_DIR}/pacman.conf"
    echo > $p
    echo "[custom]" >> $p
    echo "SigLevel = PackageRequired" >> $p
    echo "Server = file://${BUILD_REPO_DIR}" >> $p

    echo "copy local repo to iso"
    cp -r ${BUILD_REPO_DIR} "${ISO_ROOT}"

    echo "copy scripts and configs to iso"
    mkdir -p ${INSTALLER_DIR}
    git --work-tree=${INSTALLER_DIR} checkout HEAD -- .

    # https://wiki.archlinux.org/title/Archiso#Build_the_ISO
    echo "building iso"
    sudo mkarchiso -v -w "${BUILD_DIR}/archiso-tmp" -o ${BUILD_DIR} ${BUILD_ISO_DIR}
}

function main() {
    init
    build_local_repo
    build_custom_iso
}

main

