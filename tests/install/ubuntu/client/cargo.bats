#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/client/cargo.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_cargo
}

@test "[ubuntu-client] cargo is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v cargo)" ]
}
