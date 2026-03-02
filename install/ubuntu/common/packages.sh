#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

PACKAGES=(
    curl
    git
    unzip
    wget
    zsh
)

function install_packages() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get update
    local to_install=()
    for pkg in "${PACKAGES[@]}"; do
        command -v "$pkg" >/dev/null 2>&1 || to_install+=("$pkg")
    done
    if [ "${#to_install[@]}" -gt 0 ]; then
        ${SUDO} apt-get install -y "${to_install[@]}"
    fi
}

function uninstall_packages() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_packages
fi
