#!/usr/bin/env nu

const build_dir = "build"
const build_repo_dir = $"($build_dir)/repo"
const build_iso_dir = $"($build_dir)/iso"
const repo_name = "custom"
const repo_file = $"($build_repo_dir)/($repo_name).db.tar.gz"
const archiso_profile_dir = "/usr/share/archiso/configs/releng"
const iso_root_dir = $"($build_iso_dir)/airootfs/root"
const installer_dir = $"($iso_root_dir)/installer"
const configs_dir = "configs"
const archiso_work_dir = "/tmp/archiso-tmp"

def main [] {
    print "mkiso start"

    print "build local repo"
    build_local_repo

    print "build custom iso"
    build_custom_iso

    print "mkiso success"
}

def build_local_repo [] {
    let packages = load_packages
    print $"begin to handle ($packages | length) packages"

    mkdir $build_repo_dir
    # https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Installing_packages_from_a_CD/DVD_or_USB_stick
    sudo pacman -Syw --cachedir $build_repo_dir --dbpath $build_repo_dir ...$packages
    let package_zsts = ls $build_repo_dir
        | where ($it.name | str ends-with '.pkg.tar.zst')
        | get name
    repo-add ($repo_file) ...$package_zsts
}


# build a custom iso
#
# all packages needed to build iso will be fetched from the local repo
# the local repo will be copied to `/root` for bootstrap in the offline mode
# the project will be copied to `/root`
def build_custom_iso [] {
    # https://wiki.archlinux.org/title/Archiso#Installation
    rm -fr $build_iso_dir
    cp -r $archiso_profile_dir $build_iso_dir

    # add nushell to the installation env
    "nushell" | save $"($build_iso_dir)/packages.x86_64" --append

    print "copy local repo to iso"
    cp -r $build_repo_dir $iso_root_dir

    print "copy scripts and configs to iso"
    mkdir $installer_dir
    ls | where name != "build" | each {cp -r $in.name $installer_dir}

    # https://wiki.archlinux.org/title/archiso#Adding_files_to_image
    print $"copy our custom profiledef.sh to ($build_iso_dir)"
    cp $"($configs_dir)/profiledef.sh" $build_iso_dir

    # https://wiki.archlinux.org/title/Archiso#Build_the_ISO
    print "building iso"
    sudo rm -fr $archiso_work_dir
    sudo mkarchiso -v -w $archiso_work_dir -o $build_dir $build_iso_dir
}

def load_packages [] {
    let path = "configs/packages.txt"
    open $path
    | lines
    | str trim
    | filter {|it| ($it != "") and not ($it | str starts-with '#')}
}