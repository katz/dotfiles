#!/usr/bin/env bash
set -Euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly REPO_URL="https://github.com/katz/dotfiles_claude.git"
readonly RULES_DIR="${HOME}/.claude/rules"

function install_claude_rules() {
    if ! command -v git &>/dev/null; then
        echo "git not found, skipping claude rules sync"
        return 0
    fi

    if ! git ls-remote "$REPO_URL" HEAD >/dev/null 2>&1; then
        echo "cannot access $REPO_URL, skipping claude rules sync"
        return 0
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)

    git clone --depth 1 --quiet "$REPO_URL" "$tmp_dir"
    mkdir -p "$RULES_DIR"
    cp "$tmp_dir"/rules/*.md "$RULES_DIR/"
    rm -rf "$tmp_dir"

    echo "claude rules synced to $RULES_DIR"
}

function uninstall_claude_rules() {
    :
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_claude_rules
fi
