#!/usr/bin/env bash
set -euo pipefail

# root でない場合は sudo を使用
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
fi

${SUDO} pacman -Syu --noconfirm \
  git \
  zsh \
  curl \
  wget \
  unzip
