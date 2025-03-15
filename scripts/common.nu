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
