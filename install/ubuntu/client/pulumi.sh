#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_pulumi() {
    curl -fsSL https://get.pulumi.com | sh
}

function uninstall_pulumi() {
    rm -rf "${HOME}/.pulumi"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_pulumi
fi
