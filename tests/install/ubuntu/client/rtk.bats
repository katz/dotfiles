#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/client/rtk.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_rtk
}

@test "[ubuntu-client] rtk is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v rtk)" ]
}
