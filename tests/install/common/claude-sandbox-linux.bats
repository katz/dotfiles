#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/common/claude-sandbox-linux.sh"

function setup() {
    if [[ "$(uname -s)" != "Linux" ]]; then
        skip "sandbox deps require apt (Linux only)"
    fi
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_claude_sandbox
}

@test "[common] bubblewrap is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v bwrap)" ]
}

@test "[common] socat is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v socat)" ]
}
