#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

PACKAGES=(
    bat
    busybox
    curl
	direnv
	fzf
	gh
	git-delta
	gpg
    htop
    jq
	peco
	python3
	rbenv
	ripgrep
	shellcheck
    unzip
    vim
    wget
    zoxide
    zsh
)

function install_misc() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y "${PACKAGES[@]}"

    # Ubuntu では bat が batcat としてインストールされるためシンボリックリンクを作成する
    if command -v batcat &>/dev/null; then
        mkdir -p "${HOME}/.local/bin"
        ln -sf /usr/bin/batcat "${HOME}/.local/bin/bat"
    fi
}

function uninstall_misc() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_misc
fi
