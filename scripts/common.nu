#!/usr/bin/env nu

def main [] {}

def "main packages" [] {
    load_packages
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
