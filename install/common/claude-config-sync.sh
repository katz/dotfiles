#!/usr/bin/env bash
set -Euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly REPO_URL="https://github.com/katz/dotfiles_claude.git"
readonly CLAUDE_DIR="${HOME}/.claude"
readonly SYNC_DIRS=(rules skills)

# 同期元のサブフォルダ単位で同期する
# - 同期元にあるサブフォルダ → 同期先を同期元の内容に揃える
# - 同期先にしかないサブフォルダ → そのまま維持
# - 同期元のルート直下のファイル → 同期先にコピー（上書き）
function sync_dir() {
    local src_dir="$1"
    local dst_dir="$2"

    mkdir -p "$dst_dir"

    # ルート直下のファイルをコピー
    find "$src_dir" -maxdepth 1 -type f -exec cp {} "$dst_dir/" \;

    # サブフォルダ単位で同期
    local subdir
    for subdir in "$src_dir"/*/; do
        [ -d "$subdir" ] || continue
        local name
        name=$(basename "$subdir")
        rm -rf "${dst_dir:?}/$name"
        cp -r "$subdir" "$dst_dir/$name"
    done
}

function install_claude_config_sync() {
    if ! command -v git &>/dev/null; then
        echo "git not found, skipping claude config sync"
        return 0
    fi

    if ! git ls-remote "$REPO_URL" HEAD >/dev/null 2>&1; then
        echo "cannot access $REPO_URL, skipping claude config sync"
        return 0
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)

    git clone --depth 1 --quiet "$REPO_URL" "$tmp_dir"

    local dir
    for dir in "${SYNC_DIRS[@]}"; do
        if [ -d "$tmp_dir/$dir" ]; then
            sync_dir "$tmp_dir/$dir" "$CLAUDE_DIR/$dir"
        fi
    done

    rm -rf "$tmp_dir"

    echo "claude config synced to $CLAUDE_DIR"
}

function uninstall_claude_config_sync() {
    :
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_claude_config_sync
fi
