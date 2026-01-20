#!/usr/bin/env nu

use scripts/common.nu *

const build_dir = "build"
const repo_name = "custom"
const archiso_profile_dir = "/usr/share/archiso/configs/releng"
const configs_dir = "configs"
const archiso_work_dir = "/tmp/archiso-tmp"

def main [
  --ignore_build_repo # 忽略构建本地 repo.
] {
    print "mkiso start"

    print "select a profile:"
    let profile_names = get_profiles
    let profile_name = $profile_names | input list
    print $"select profile: ($profile_name)"

    let profile = load_profile $profile_name

    if not $ignore_build_repo {
      print "build local repo"
      build_local_repo $profile_name $profile      
    }

    print "build custom iso"
    build_custom_iso $profile_name $profile

    print "mkiso success"
}

def build_local_repo [profile_name: string, profile] {
    let packages = $profile.packages
    print $"begin to handle ($packages | length) packages"

    let build_repo_dir = build_repo_dir $profile_name
    mkdir $build_repo_dir
    # https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#Installing_packages_from_a_CD/DVD_or_USB_stick
    sudo pacman -Syw --cachedir $build_repo_dir --dbpath $build_repo_dir ...$packages
    let package_zsts = ls $build_repo_dir
        | where ($it.name | str ends-with '.pkg.tar.zst')
        | get name
    repo-add (repo_file $profile_name) ...$package_zsts
}

# build a custom iso
#
# all packages needed to build iso will be fetched from the local repo
# the local repo will be copied to `/root` for bootstrap in the offline mode
# the project will be copied to `/root`
def build_custom_iso [profile_name: string, profile] {
    let build_iso_dir = build_iso_dir $profile_name
    let installer_dir = installer_dir $profile_name
    # https://wiki.archlinux.org/title/Archiso#Installation
    rm -fr $build_iso_dir
    cp -r $archiso_profile_dir $build_iso_dir

    # add nushell to the installation env
    "nushell" | save $"($build_iso_dir)/packages.x86_64" --append

    print "copy local repo to iso"
    cp -r (build_repo_dir $profile_name) (iso_root_dir $profile_name)

    print "copy scripts and configs to iso"
    mkdir $installer_dir
    # generate profile
    ls | where name != "build" and name != "profiles" | each {cp -r $in.name $installer_dir}
    $profile | save ($installer_dir + "/profile.nuon")

    # install archconfig
    let archconfig_dir = $env.HOME + "/archconfig"
    if ($archconfig_dir | path exists ) {
      print "install archconfig"
      let tar_name = $installer_dir + "/archconfig.tar.gz" | path expand
      do {
        cd $env.HOME
        tar czf $tar_name "archconfig"        
      }
    }

    # https://wiki.archlinux.org/title/archiso#Adding_files_to_image
    print $"copy our custom profiledef.sh to ($build_iso_dir)"
    cp $"($configs_dir)/profiledef.sh" $build_iso_dir

    # https://wiki.archlinux.org/title/Archiso#Build_the_ISO
    print "building iso"
    sudo rm -fr $archiso_work_dir
    sudo mkarchiso -v -w $archiso_work_dir -o (build_profile_dir $profile_name) $build_iso_dir
}

def build_profile_dir [profile_name: string] {
    $"($build_dir)/($profile_name)"
}

def build_repo_dir [profile_name: string] {
    $"(build_profile_dir $profile_name)/repo"
}

def build_iso_dir [profile_name: string] {
    $"(build_profile_dir $profile_name)/iso"
}

def repo_file [profile_name: string] {
    $"(build_repo_dir $profile_name)/($repo_name).db.tar.gz"
}

def iso_root_dir [profile_name: string] {
    $"(build_iso_dir $profile_name)/airootfs/root"
}

def installer_dir [profile_name: string] {
    $"(iso_root_dir $profile_name)/installer"
}
