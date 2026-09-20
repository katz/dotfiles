#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function run_rtk() {
    if command -v rtk &>/dev/null; then
        rtk "$@"
    elif [ -x "${HOME}/.local/bin/mise" ]; then
        "${HOME}/.local/bin/mise" exec -- rtk "$@"
    else
        return 127
    fi
}

function install_rtk_opencode() {
    if ! run_rtk init -g --opencode; then
        echo "rtk not found, skipping opencode integration"
        return 0
    fi
}

function uninstall_rtk_opencode() {
    rm -f "${HOME}/.config/opencode/plugins/rtk.ts"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_rtk_opencode
fi