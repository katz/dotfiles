#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/macos/common/packages.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_packages
}

@test "[macos-common] PACKAGES contains expected tools" {
    expected_packages=(
        starship
    )
    [ "${#PACKAGES[@]}" -eq "${#expected_packages[@]}" ]
    for ((i = 0; i < ${#expected_packages[*]}; ++i)); do
        [ "${PACKAGES[$i]}" = "${expected_packages[$i]}" ]
    done
}

@test "[macos-common] packages are available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    [ -x "$(command -v starship)" ]
}
