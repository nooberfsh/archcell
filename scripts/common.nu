#!/usr/bin/env nu

def main [] {}

def "main packages" [] {
    load_packages
}

export def load_packages [] {
    open "configs/packages.nuon" | get core
}
