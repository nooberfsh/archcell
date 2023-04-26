#!/usr/bin/env bash

set -e

function load_packages() {
    local path=$1
    # assign `packages` parameter
    # https://stackoverflow.com/a/57182468
    declare -n __packages=$2
    # read will trim line
    while read line; do
        if [[ -n $line && ! ($line == '#'*) ]]; then
            __packages+=($line)
        fi
    done < "$path"
}
