#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_claude_cli() {
    curl -fsSL https://claude.ai/install.sh | bash
}

function uninstall_claude_cli() {
    rm -f "${HOME}/.local/bin/claude"
    rm -rf "${HOME}/.local/share/claude"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_claude_cli
fi
