#!/usr/bin/env nu

def main [] {}

def "main profiles" [] {
    get_profiles
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

export def get_network_profiles [] {
    let profiles = (
        ls -s profiles/network
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

export def load_network_profile [
    name: string
] {
  let s = $"profiles/network/($name).nuon"
  open $s
}

export def merge_profile [lhs, rhs] {
  {
    packages: ($lhs.packages ++ $rhs.packages)
    services: ($lhs.services ++ $rhs.services)
  }  
}
