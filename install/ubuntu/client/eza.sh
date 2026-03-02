#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

PACKAGES=(
    eza
)

function setup_repository() {
    # Install gpg if not present
    sudo apt-get update
    sudo apt-get install -y gpg wget

    # Add eza's official GPG key
    sudo mkdir -p /etc/apt/keyrings
    wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
        | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg

    # Set up the repository
    echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" \
        | sudo tee /etc/apt/sources.list.d/gierens.list >/dev/null

    sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
}

function install_eza() {
    sudo apt-get update
    sudo apt-get install -y "${PACKAGES[@]}"
}

function uninstall_eza() {
    sudo apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
}

function main() {
    setup_repository
    install_eza
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
