#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

PACKAGES=(
    oha
)

function setup_repository() {
    # Add oha's official GPG key
    sudo wget -O /usr/share/keyrings/azlux-archive-keyring.gpg https://azlux.fr/repo.gpg

    # Set up the repository
    echo "deb [signed-by=/usr/share/keyrings/azlux-archive-keyring.gpg] http://packages.azlux.fr/debian/ stable main" \
        | sudo tee /etc/apt/sources.list.d/azlux.list >/dev/null
}

function install_oha() {
    sudo apt-get update
    sudo apt-get install -y "${PACKAGES[@]}"
}

function uninstall_oha() {
    sudo apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
}

function main() {
    setup_repository
    install_oha
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
