#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_dockle() {
    if "${CI:-false}"; then
        brew info goodwithtech/r/dockle
    else
        brew install goodwithtech/r/dockle
    fi
}

function uninstall_dockle() {
    brew uninstall dockle 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_dockle
fi
