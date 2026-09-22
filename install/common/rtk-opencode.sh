#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# NOTE: rtk <= 0.49.0 が書き出す OpenCode プラグインは v1 形式（named export のみ）で、
# OpenCode v2 は default エクスポート（{ id, effect | setup }）を要求するため読み込まれない。
# そのため opencode v2 では rtk rewrite によるトークン削減が効かない（既知の回帰）。
# 上流 rtk-ai/rtk#3898 / #4059 が v2 対応するまで許容する。
function run_rtk() {
    if command -v rtk &>/dev/null; then
        rtk "$@"
    elif [ -x "${HOME}/.local/bin/mise" ]; then
        "${HOME}/.local/bin/mise" exec -- rtk "$@"
    else
        return 127
    fi
}

function install_rtk_opencode() {
    if ! run_rtk init -g --opencode; then
        echo "rtk not found, skipping opencode integration"
        return 0
    fi
}

function uninstall_rtk_opencode() {
    rm -f "${HOME}/.config/opencode/plugins/rtk.ts"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_rtk_opencode
fi