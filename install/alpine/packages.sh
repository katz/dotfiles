#!/bin/sh
set -eu

# root でない場合は sudo を使用
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
fi

${SUDO} apk update
${SUDO} apk add --no-cache \
  git \
  zsh \
  curl \
  wget \
  unzip \
  bash
