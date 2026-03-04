#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly BIN_DIR="${HOME}/.local/bin"

function install_rtk() {
    mkdir -p "${BIN_DIR}"
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh
}

function uninstall_rtk() {
    rm -f "${BIN_DIR}/rtk"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_rtk
fi
