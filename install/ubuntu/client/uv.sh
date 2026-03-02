#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_uv() {
    curl -LsSf https://astral.sh/uv/install.sh | sh
}

function uninstall_uv() {
    rm -f "${HOME}/.local/bin/uv" "${HOME}/.local/bin/uvx"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_uv
fi
