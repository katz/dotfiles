#!/usr/bin/env bash
set -Euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly REPO_URL="https://github.com/katz/dotfiles_claude.git"
readonly CLAUDE_DIR="${HOME}/.claude"
readonly RULES_DIR="${CLAUDE_DIR}/rules"
readonly SKILLS_DIR="${CLAUDE_DIR}/skills"

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

    if [ -d "$tmp_dir/rules" ]; then
        mkdir -p "$RULES_DIR"
        cp "$tmp_dir"/rules/*.md "$RULES_DIR/"
    fi

    if [ -d "$tmp_dir/skills" ]; then
        mkdir -p "$SKILLS_DIR"
        cp -r "$tmp_dir"/skills/* "$SKILLS_DIR/"
    fi

    rm -rf "$tmp_dir"

    echo "claude rules and skills synced to $CLAUDE_DIR"
}

function uninstall_claude_config_sync() {
    :
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_claude_config_sync
fi
