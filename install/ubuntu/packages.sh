#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y \
  git \
  zsh \
  curl \
  wget \
  unzip
