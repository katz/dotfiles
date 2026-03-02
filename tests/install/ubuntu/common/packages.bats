#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/common/packages.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_packages
}

@test "[ubuntu-common] PACKAGES contains expected tools" {
    expected_packages=(
        curl
        git
        unzip
        wget
        zsh
    )
    [ "${#PACKAGES[@]}" -eq "${#expected_packages[@]}" ]
    for ((i = 0; i < ${#expected_packages[*]}; ++i)); do
        [ "${PACKAGES[$i]}" = "${expected_packages[$i]}" ]
    done
}

@test "[ubuntu-common] packages are available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    [ -x "$(command -v git)" ]
    [ -x "$(command -v zsh)" ]
    [ -x "$(command -v curl)" ]
}
