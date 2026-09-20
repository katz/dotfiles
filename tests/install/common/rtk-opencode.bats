#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/common/rtk-opencode.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_rtk_opencode
}

@test "[common] rtk-opencode script exists" {
    [ -f "${SCRIPT_PATH}" ]
}

@test "[common] rtk opencode plugin is installed" {
    if ! command -v rtk >/dev/null 2>&1 && [ ! -x "${HOME}/.local/bin/mise" ]; then
        skip "rtk is not available"
    fi

    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -f "${HOME}/.config/opencode/plugins/rtk.ts" ]
}