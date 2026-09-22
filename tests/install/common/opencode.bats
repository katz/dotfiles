#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/common/opencode.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_opencode
}

@test "[common] opencode script exists" {
    [ -f "${SCRIPT_PATH}" ]
}

@test "[common] opencode is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "${HOME}/.opencode/bin/opencode" ]
    "${HOME}/.opencode/bin/opencode" --version
}
