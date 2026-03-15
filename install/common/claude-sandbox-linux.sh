#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Claude Code のサンドボックス機能に必要なパッケージ
readonly PACKAGES=(bubblewrap socat)

function install_claude_sandbox() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y "${PACKAGES[@]}"
}

function uninstall_claude_sandbox() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_claude_sandbox
fi
