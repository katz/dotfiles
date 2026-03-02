#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

PACKAGES=(
    busybox
    curl
    gpg
    htop
    jq
    unzip
    vim
    wget
    zsh
)

function install_misc() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y "${PACKAGES[@]}"
}

function uninstall_misc() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_misc
fi
