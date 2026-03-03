#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/common/zoxide.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_zoxide
}

@test "[ubuntu-common] zoxide is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v zoxide)" ]
}
