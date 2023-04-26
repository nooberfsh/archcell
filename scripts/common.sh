#!/usr/bin/env bash

set -e

export PACKAGES=()

function load_packages() {
    local path=$1
    # read will trim line
    while read line; do
        if [[ -n $line && ! ($line == '#'*) ]]; then
            PACKAGES+=($line)
        fi
    done < "$path"
}

