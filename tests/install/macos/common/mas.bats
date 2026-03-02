#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/macos/common/mas.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_mas
}

@test "[macos-common] mas is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    [ -x "$(command -v mas)" ]
}
