#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/client/eza.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_eza
}

@test "[ubuntu-client] eza is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v eza)" ]
}
