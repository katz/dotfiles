#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/client/oha.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_oha
}

@test "[ubuntu-client] oha is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v oha)" ]
}
