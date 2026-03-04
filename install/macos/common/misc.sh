#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

BREW_PACKAGES=(
    bat
    vim
    htop
    apktool
    argocd
    certifi
    aws-sam-cli
    awscli
    azure-cli
    biome
    blueutil
    cloudflared
    cmake
    lima
    colima
    coreutils
    curl
    direnv
    dive
    exif
    exiftool
    eza
    ffmpeg
    fzf
    gh
    ghalint
    ghq
    git-delta
    go
    gpac
    graphviz
    gron
    hadolint
    helm
    hey
    jq
    kubectx
    kustomize
    libffi
    mas
    media-info
    mysql-client
    nmap
    oha
    peco
    pinact
    pkgconf
    poetry
    uv
    poppler
    pulumi
    pyenv
    python
    rbenv
    ripgrep
    rustscan
    samba
    shellcheck
    telnet
    tflint
    tfsec
    tnftp
    trivy
    unshield
    vim
    wget
    yq
    yt-dlp
    zoxide
)

CASK_PACKAGES=(
    1password-cli
    alfred
    charles
    cyberduck
    devtoys
    discord
    docker-desktop
    evernote
    firefox
    font-cica
    font-hackgen
    font-hackgen-nerd
    font-ibm-plex-mono
    font-noto-sans-cjk-jp
    font-plemol-jp
    gcloud-cli
    ghostty
    git-credential-manager
    google-chrome
    iterm2
    jordanbaird-ice
    karabiner-elements
    ngrok
    obs
    postman
    powershell
    proxyman
    rectangle-pro
    session-manager-plugin
    stoplight-studio
    teamviewer
    visual-studio-code
    vivaldi
    vlc
    zoom
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
