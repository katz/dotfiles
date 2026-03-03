#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/macos/common/dockle.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_dockle
}

@test "[macos-common] dockle is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    run brew info goodwithtech/r/dockle
    [ "${status}" -eq 0 ]
}
