#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/macos/common/homebrew.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    : # Homebrew のアンインストールは重すぎるため省略
}

@test "[macos-common] homebrew script exists" {
    [ -f "${SCRIPT_PATH}" ]
}

@test "[macos-common] homebrew is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    [ -x "$(command -v brew)" ]
}
