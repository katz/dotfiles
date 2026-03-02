#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/client/trivy.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_trivy
}

@test "[ubuntu-client] trivy is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v trivy)" ]
}
