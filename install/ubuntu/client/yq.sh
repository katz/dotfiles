#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly BIN_DIR="${HOME}/.local/bin"

function detect_arch() {
    case "$(uname -m)" in
        x86_64)  echo "amd64" ;;
        aarch64) echo "arm64" ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac
}

function install_yq() {
    local arch
    arch="$(detect_arch)"

    mkdir -p "${BIN_DIR}"
    wget "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${arch}" \
        -O "${BIN_DIR}/yq"
    chmod +x "${BIN_DIR}/yq"
}

function uninstall_yq() {
    rm -f "${BIN_DIR}/yq"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_yq
fi
