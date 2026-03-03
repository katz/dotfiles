#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_cargo() {
    # Install Rust and cargo via rustup (non-interactive)
    curl https://sh.rustup.rs -sSf | sh -s -- -y
}

function uninstall_cargo() {
    rustup self uninstall -y 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_cargo
fi
