#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

BREW_PACKAGES=(
    git
    vim
    htop
    jq
    ghq
)

CASK_PACKAGES=(
    google-chrome
    google-japanese-ime
    rectangle
    visual-studio-code
)

function is_brew_package_installed() {
    local package="$1"
    brew list "${package}" &>/dev/null
}

function install_brew_packages() {
    local missing_packages=()

    for package in "${BREW_PACKAGES[@]}"; do
        if ! is_brew_package_installed "${package}"; then
            missing_packages+=("${package}")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        if "${CI:-false}"; then
            brew info "${missing_packages[@]}"
        else
            brew install --force "${missing_packages[@]}"
        fi
    fi
}

function install_cask_packages() {
    local missing_packages=()

    for package in "${CASK_PACKAGES[@]}"; do
        if ! is_brew_package_installed "${package}"; then
            missing_packages+=("${package}")
        fi
    done

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        if "${CI:-false}"; then
            brew info --cask "${missing_packages[@]}"
        else
            brew install --cask --force "${missing_packages[@]}"
        fi
    fi
}

function uninstall_misc() {
    brew uninstall --ignore-dependencies "${BREW_PACKAGES[@]}" 2>/dev/null || true
    brew uninstall --cask --force "${CASK_PACKAGES[@]}" 2>/dev/null || true
}

function main() {
    install_brew_packages
    install_cask_packages
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
