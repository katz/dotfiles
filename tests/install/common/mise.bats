#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/common/mise.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_mise
    PATH=$(getconf PATH)
    export PATH
}

@test "[common] mise script exists" {
    [ -f "${SCRIPT_PATH}" ]
}

@test "[common] mise is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    export PATH="${HOME}/.local/bin:${PATH}"
    [ -x "$(command -v mise)" ]
}
