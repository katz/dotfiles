#!/bin/sh
set -eu

GITHUB_USER="katz"

# chezmoi がなければインストール
if ! command -v chezmoi >/dev/null 2>&1; then
  sh -c "$(curl -fsLS get.chezmoi.io)"
fi

# dotfiles を適用
chezmoi init --apply "${GITHUB_USER}"
