#!/usr/bin/env nu

def main [] {}

def "main packages" [] {
    load_packages
}

export def get_profiles [] {
    let profiles = (
        ls -s profiles
        | get name
        | filter {|el| $el | str ends-with '.nuon'}
        | str replace '.nuon' ''
    )

    $profiles
}

export def load_profile [
    name: string
] {
  let s = $"profiles/($name).nuon"
  open $s
}

export def cp_profile [
    name: string
    dest: string
] {
  let s = $"profiles/($name).nuon"
  cp $s $"($dest)/profile.nuon"
}

export def load_packages [] {
    let packages = open "configs/packages.nuon"
    let profiles = ['default', 'minimum']
    print "choose which profile to use:"
    let profile = $profiles | input list
    match $profile {
        'default' => ($packages.core ++ $packages.extra)
        'minimum' => $packages.core
         _ => (error make {msg: $"invalid profile: ($profile)"})
    }
}
