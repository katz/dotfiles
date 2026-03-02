#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/common/misc.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_misc

    PATH=$(getconf PATH)
    export PATH
}

@test "[ubuntu-common] PACKAGES for misc" {
    num_packages="${#PACKAGES[@]}"
    [ $num_packages -eq 5 ]

    expected_packages=(
        busybox
        gpg
        htop
        jq
        vim
    )
    for ((i = 0; i < ${#expected_packages[*]}; ++i)); do
        [ "${PACKAGES[$i]}" == "${expected_packages[$i]}" ]
    done
}

@test "[ubuntu-common] misc packages are available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v busybox)" ]
    [ -x "$(command -v gpg)" ]
    [ -x "$(command -v htop)" ]
    [ -x "$(command -v jq)" ]
    [ -x "$(command -v vim)" ]
}
