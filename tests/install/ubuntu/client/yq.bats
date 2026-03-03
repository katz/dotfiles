#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/client/yq.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_yq
}

@test "[ubuntu-client] yq is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v yq)" ]
}
