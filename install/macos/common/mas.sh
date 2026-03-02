#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

# Mac App Store app IDs to install.
# Find app IDs with: mas search <app-name>
MAS_APPS=(
    1569813296  # 1password_for_safari
    1037126344  # apple_configurator
	1024640650  # coteditor
	1444383602  # goodnotes
	1487860882  # imazing_profile_editor
	414781829   # keeper
	302584613   # kindle
	510620098   # mediainfo
	1289583905  # pixelmator
	425955336	# skitch
	803453959	# slack
	425424353	# the_unarchiver
	1380563956	# jisho_by_monokakido
)

function install_mas() {
    if ! command -v mas &>/dev/null; then
        brew install mas
    fi
}

function uninstall_mas() {
    brew uninstall --ignore-dependencies mas 2>/dev/null || true
}

function install_mas_apps() {
    if [ "${#MAS_APPS[@]}" -eq 0 ]; then
        return
    fi
    for app_id in "${MAS_APPS[@]}"; do
        mas install "${app_id}"
    done
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_mas
    if [ "${CI:-}" != "true" ]; then
        install_mas_apps
    fi
fi
