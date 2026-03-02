#!/bin/sh
set -eu

GITHUB_USER="katz"

if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)"
    export PATH="${HOME}/bin:${PATH}"
fi

chezmoi init --apply "${GITHUB_USER}"
