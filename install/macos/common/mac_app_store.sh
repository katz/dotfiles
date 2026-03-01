#!/usr/bin/env bash

set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function is_mas_installed() {
    common -v mas &>/dev/null
}

function install_mas() {
    if ! is_mas_installed; then
        brew install mas
    fi
}

function run_mas_install() {
    local app_id="$1"
    mas install "${app_id}"
}

function install_1password_for_safari() {
    local app_id="1569813296"
    run_mas_install "${app_id}"
}

function install_apple_configurator() {
    local app_id="1037126344"
    run_mas_install "${app_id}"
}

function install_coteditor() {
    local app_id="1024640650"
    run_mas_install "${app_id}"
}

function install_goodnotes() {
    local app_id="1444383602"
    run_mas_install "${app_id}"
}

function install_imazing_profile_editor() {
    local app_id="1487860882"
    run_mas_install "${app_id}"
}

function install_keeper() {
    local app_id="414781829"
    run_mas_install "${app_id}"
}

function install_kindle() {
    local app_id="302584613"
    run_mas_install "${app_id}"
}

function install_mediainfo() {
    local app_id="510620098"
    run_mas_install "${app_id}"
}

function install_pixelmator() {
    local app_id="1289583905"
    run_mas_install "${app_id}"
}

function install_skitch() {
    local app_id="425955336"
    run_mas_install "${app_id}"
}

function install_slack() {
    local app_id="803453959"
    run_mas_install "${app_id}"
}

function install_the_unarchiver() {
    local app_id="425424353"
    run_mas_install "${app_id}"
}

function install_jisho_by_monokakido() {
    local app_id="1380563956"
    run_mas_install "${app_id}"
}


function main() {
    install_mas

    if ! "${CI:-false}"; then
        install_1password_for_safari
		install_apple_configurator
		install_coteditor
		install_goodnotes
		install_imazing_profile_editor
		install_keeper
		install_kindle
		install_mediainfo
		install_pixelmator
		install_skitch
		install_slack
		install_the_unarchiver
		install_jisho_by_monokakido
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
