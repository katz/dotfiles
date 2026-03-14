#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function detect_arch() {
    case "$(uname -m)" in
        x86_64)  echo "64bit" ;;
        aarch64) echo "ARM64" ;;
        *)
            echo "Unsupported architecture: $(uname -m)" >&2
            exit 1
            ;;
    esac
}

function install_dockle() {
    local arch version
    arch="$(detect_arch)"
    version=$(
        curl --silent \
            ${GITHUB_TOKEN:+-H "Authorization: Bearer ${GITHUB_TOKEN}"} \
            "https://api.github.com/repos/goodwithtech/dockle/releases/latest" \
        | grep '"tag_name":' \
        | sed -E 's/.*"v([^"]+)".*/\1/'
    )

    local deb_file="dockle_${version}_Linux-${arch}.deb"
    local tmp_dir
    tmp_dir="$(mktemp -d)"

    curl -L -o "${tmp_dir}/${deb_file}" \
        "https://github.com/goodwithtech/dockle/releases/download/v${version}/${deb_file}"

    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    else
        SUDO=""
    fi

    ${SUDO} dpkg -i "${tmp_dir}/${deb_file}"
    rm -rf "${tmp_dir}"
}

function uninstall_dockle() {
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    else
        SUDO=""
    fi
    ${SUDO} dpkg --purge dockle 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_dockle
fi
