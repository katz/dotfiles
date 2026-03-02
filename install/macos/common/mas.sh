#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Mac App Store app IDs to install.
# Find app IDs with: mas search <app-name>
MAS_APPS=(
    # 539883307  # LINE
    # 497799835  # Xcode
)

function install_mas() {
    if ! command -v mas &>/dev/null; then
        brew install mas
    fi
}

function uninstall_mas() {
    brew uninstall --ignore-dependencies mas 2>/dev/null || true
}

function install_mas_apps() {
    if [ "${#MAS_APPS[@]}" -eq 0 ]; then
        return
    fi
    for app_id in "${MAS_APPS[@]}"; do
        mas install "${app_id}"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_mas
    if [ "${CI:-}" != "true" ]; then
        install_mas_apps
    fi
fi
