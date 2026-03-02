#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

PACKAGES=(
    sheldon
    starship
)

function install_packages() {
    brew install "${PACKAGES[@]}"
}

function uninstall_packages() {
    brew uninstall --ignore-dependencies "${PACKAGES[@]}" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_packages
fi
