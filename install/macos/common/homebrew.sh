#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already installed"
        return 0
    fi
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_homebrew
fi
