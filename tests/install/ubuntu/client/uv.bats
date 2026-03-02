#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/client/uv.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_uv
}

@test "[ubuntu-client] uv is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v uv)" ]
}
