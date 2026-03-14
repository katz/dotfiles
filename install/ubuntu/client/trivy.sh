#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

PACKAGES=(
    trivy
)

function setup_repository() {
    # Install prerequisites
    sudo apt-get update
    sudo apt-get install -y wget gnupg

    # Add Trivy's official GPG key
    wget -qO - https://aquasecurity.github.io/trivy-repo/deb/public.key \
        | gpg --dearmor \
        | sudo tee /usr/share/keyrings/trivy.gpg >/dev/null

    # Set up the repository
    echo "deb [signed-by=/usr/share/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" \
        | sudo tee /etc/apt/sources.list.d/trivy.list >/dev/null
}

function install_trivy() {
    sudo apt-get update
    sudo apt-get install -y "${PACKAGES[@]}"
}

function uninstall_trivy() {
    sudo apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
}

function main() {
    setup_repository
    install_trivy
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
