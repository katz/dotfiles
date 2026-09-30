#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/common/op.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_op
}

@test "[ubuntu-common] 1password-cli is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v op)" ]
}
