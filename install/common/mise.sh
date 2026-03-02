#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_mise() {
    curl -fsSL https://mise.run | sh
}

function uninstall_mise() {
    rm -f "${HOME}/.local/bin/mise"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_mise
fi
