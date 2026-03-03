#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly BIN_DIR="${HOME}/.local/bin"

function install_starship() {
    curl -sS https://starship.rs/install.sh | sh -s -- --yes --bin-dir "${BIN_DIR}"
}

function uninstall_starship() {
    rm -f "${BIN_DIR}/starship"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_starship
fi
