#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/client/pulumi.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_pulumi
}

@test "[ubuntu-client] pulumi is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "${HOME}/.pulumi/bin/pulumi" ]
}
