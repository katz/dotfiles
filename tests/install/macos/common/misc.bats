#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/macos/common/misc.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

@test "[macos-common] misc" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    #
    # brew packages
    #
    run brew info vim
    [ "${status}" -eq 0 ]
    run brew info htop
    [ "${status}" -eq 0 ]
    run brew info apktool
    [ "${status}" -eq 0 ]
    run brew info argocd
    [ "${status}" -eq 0 ]
    run brew info certifi
    [ "${status}" -eq 0 ]
    run brew info aws-sam-cli
    [ "${status}" -eq 0 ]
    run brew info awscli
    [ "${status}" -eq 0 ]
    run brew info azure-cli
    [ "${status}" -eq 0 ]
    run brew info biome
    [ "${status}" -eq 0 ]
    run brew info blueutil
    [ "${status}" -eq 0 ]
    run brew info cloudflared
    [ "${status}" -eq 0 ]
    run brew info cmake
    [ "${status}" -eq 0 ]
    run brew info lima
    [ "${status}" -eq 0 ]
    run brew info colima
    [ "${status}" -eq 0 ]
    run brew info coreutils
    [ "${status}" -eq 0 ]
    run brew info curl
    [ "${status}" -eq 0 ]
    run brew info direnv
    [ "${status}" -eq 0 ]
    run brew info dive
    [ "${status}" -eq 0 ]
    run brew info exif
    [ "${status}" -eq 0 ]
    run brew info exiftool
    [ "${status}" -eq 0 ]
    run brew info eza
    [ "${status}" -eq 0 ]
    run brew info ffmpeg
    [ "${status}" -eq 0 ]
    run brew info fzf
    [ "${status}" -eq 0 ]
    run brew info gh
    [ "${status}" -eq 0 ]
    run brew info ghalint
    [ "${status}" -eq 0 ]
    run brew info ghq
    [ "${status}" -eq 0 ]
    run brew info git-delta
    [ "${status}" -eq 0 ]
    run brew info go
    [ "${status}" -eq 0 ]
    run brew info gpac
    [ "${status}" -eq 0 ]
    run brew info graphviz
    [ "${status}" -eq 0 ]
    run brew info gron
    [ "${status}" -eq 0 ]
    run brew info hadolint
    [ "${status}" -eq 0 ]
    run brew info helm
    [ "${status}" -eq 0 ]
    run brew info hey
    [ "${status}" -eq 0 ]
    run brew info jq
    [ "${status}" -eq 0 ]
    run brew info kubectx
    [ "${status}" -eq 0 ]
    run brew info kustomize
    [ "${status}" -eq 0 ]
    run brew info libffi
    [ "${status}" -eq 0 ]
    run brew info mas
    [ "${status}" -eq 0 ]
    run brew info media-info
    [ "${status}" -eq 0 ]
    run brew info mysql-client
    [ "${status}" -eq 0 ]
    run brew info nmap
    [ "${status}" -eq 0 ]
    run brew info oha
    [ "${status}" -eq 0 ]
    run brew info peco
    [ "${status}" -eq 0 ]
    run brew info pinact
    [ "${status}" -eq 0 ]
    run brew info pkgconf
    [ "${status}" -eq 0 ]
    run brew info poetry
    [ "${status}" -eq 0 ]
    run brew info uv
    [ "${status}" -eq 0 ]
    run brew info poppler
    [ "${status}" -eq 0 ]
    run brew info pulumi
    [ "${status}" -eq 0 ]
    run brew info pyenv
    [ "${status}" -eq 0 ]
    run brew info python
    [ "${status}" -eq 0 ]
    run brew info rbenv
    [ "${status}" -eq 0 ]
    run brew info ripgrep
    [ "${status}" -eq 0 ]
    run brew info rustscan
    [ "${status}" -eq 0 ]
    run brew info samba
    [ "${status}" -eq 0 ]
    run brew info shellcheck
    [ "${status}" -eq 0 ]
    run brew info telnet
    [ "${status}" -eq 0 ]
    run brew info tflint
    [ "${status}" -eq 0 ]
    run brew info tfsec
    [ "${status}" -eq 0 ]
    run brew info tnftp
    [ "${status}" -eq 0 ]
    run brew info trivy
    [ "${status}" -eq 0 ]
    run brew info unshield
    [ "${status}" -eq 0 ]
    run brew info vim
    [ "${status}" -eq 0 ]
    run brew info wget
    [ "${status}" -eq 0 ]
    run brew info yq
    [ "${status}" -eq 0 ]
    run brew info yt-dlp
    [ "${status}" -eq 0 ]
    run brew info zoxide
    [ "${status}" -eq 0 ]

    #
    # Cask packages
    #
    # Currently, we do not run this test on CI
    # because of the time it takes to install the cask packages.
}
