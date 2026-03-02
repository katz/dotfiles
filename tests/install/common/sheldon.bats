#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/common/sheldon.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_sheldon
}

@test "[common] sheldon is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    [ -x "$(command -v sheldon)" ]
}
