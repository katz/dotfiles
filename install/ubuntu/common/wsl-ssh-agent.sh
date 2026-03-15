#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly NPIPERELAY_VERSION="0.1.0"
readonly NPIPERELAY_URL="https://github.com/jstarks/npiperelay/releases/download/v${NPIPERELAY_VERSION}/npiperelay_windows_amd64.zip"
readonly NPIPERELAY_DEST="${HOME}/.local/bin/npiperelay.exe"

function install_wsl_ssh_agent() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi

    # socat のインストール
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y socat unzip

    # npiperelay のダウンロードと配置
    local tmpdir
    tmpdir=$(mktemp -d)
    curl -fsSL "${NPIPERELAY_URL}" -o "${tmpdir}/npiperelay.zip"
    unzip -o "${tmpdir}/npiperelay.zip" -d "${tmpdir}"
    mkdir -p "$(dirname "${NPIPERELAY_DEST}")"
    mv "${tmpdir}/npiperelay.exe" "${NPIPERELAY_DEST}"
    chmod +x "${NPIPERELAY_DEST}"
    rm -rf "${tmpdir}"
}

function uninstall_wsl_ssh_agent() {
    rm -f "${NPIPERELAY_DEST}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_wsl_ssh_agent
fi
