#!/usr/bin/env nu

def main [] {}

def "main profiles" [] {
    get_profiles
}

export def get_profiles [] {
    let profiles = (
        ls -s profiles
        | get name
        | filter {|el| $el | str ends-with '.cue'}
        | str replace '.cue' ''
    )

    $profiles
}


export def load_profile [
    name: string
] {
  let s = $"profiles/($name).cue"
  cue export $s | from json
}
