#!/usr/bin/env bash
set -euo pipefail

# 最低限必要なパッケージ（Brewfile は別途管理）
brew install \
  chezmoi \
  git \
  zsh \
  sheldon \
  starship
