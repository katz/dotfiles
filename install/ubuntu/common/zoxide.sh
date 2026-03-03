#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly BIN_DIR="${HOME}/.local/bin"

function install_zoxide() {
    mkdir -p "${BIN_DIR}"
    curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
}

function uninstall_zoxide() {
    rm -f "${BIN_DIR}/zoxide"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_zoxide
fi
