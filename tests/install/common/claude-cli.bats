#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/common/claude-cli.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_claude_cli
    PATH=$(getconf PATH)
    export PATH
}

@test "[common] claude-cli script exists" {
    [ -f "${SCRIPT_PATH}" ]
}

@test "[common] claude is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    export PATH="${HOME}/.local/bin:${PATH}"
    [ -x "$(command -v claude)" ]
}
