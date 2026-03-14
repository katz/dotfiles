#!/usr/bin/env bash
set -Euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

PLUGINS=(
    "Notion@claude-plugins-official"
    "claude-md-management@claude-plugins-official"
    "code-review@claude-plugins-official"
    "code-simplifier@claude-plugins-official"
    "commit-commands@claude-plugins-official"
    "feature-dev@claude-plugins-official"
    "github@claude-plugins-official"
    "pr-review-toolkit@claude-plugins-official"
    "security-guidance@claude-plugins-official"
    "skill-creator@claude-plugins-official"
    "slack@claude-plugins-official"
    "superpowers@claude-plugins-official"
)

function install_claude_plugins() {
    if ! command -v claude &>/dev/null; then
        echo "claude CLI not found, skipping plugin installation"
        return 0
    fi

    if ! claude auth status &>/dev/null; then
        echo "claude is not authenticated, skipping plugin installation"
        return 0
    fi

    for plugin in "${PLUGINS[@]}"; do
        echo "Installing plugin: $plugin"
        claude plugin install "$plugin" || echo "  Warning: Failed to install $plugin"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_claude_plugins
fi
