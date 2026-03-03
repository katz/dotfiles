#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/common/starship.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_starship
}

@test "[ubuntu-common] starship is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v starship)" ]
}
