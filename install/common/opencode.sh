#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# opencode v2 は npm (@opencode/cli) のプラットフォーム別バイナリとして配布されており、
# v2 のタグには GitHub Release が作成されていないため mise の aqua backend では導入できない (PR #143)。
# 公式の v2 インストーラで ~/.opencode/bin にネイティブバイナリを配置する。
readonly OPENCODE_VERSION="2.0.3"

function install_opencode() {
    # --no-modify-path: PATH は dot_zshrc.tmpl 側で管理する
    curl -fsSL https://opencode.ai/v2/install \
        | bash -s -- --version "${OPENCODE_VERSION}" --no-modify-path
}

function uninstall_opencode() {
    rm -rf "${HOME}/.opencode"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_opencode
fi
