#!/usr/bin/env bash
set -Eeuo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly KEYRING_PATH="/usr/share/keyrings/1password-archive-keyring.gpg"
readonly SOURCES_LIST_PATH="/etc/apt/sources.list.d/1password.list"
readonly DEBSIG_POLICY_DIR="/etc/debsig/policies/AC2D62742012EA22"
readonly DEBSIG_KEYRING_DIR="/usr/share/debsig/keyrings/AC2D62742012EA22"
readonly KEY_URL="https://downloads.1password.com/linux/keys/1password.asc"

PACKAGES=(
    1password-cli
)

function setup_repository() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi

    local arch
    arch="$(dpkg --print-architecture)"

    # Add the key for the 1Password apt repository
    curl -sS "${KEY_URL}" \
        | ${SUDO} gpg --dearmor --yes --output "${KEYRING_PATH}"

    # Add the 1Password apt repository
    echo "deb [arch=${arch} signed-by=${KEYRING_PATH}] https://downloads.1password.com/linux/debian/${arch} stable main" \
        | ${SUDO} tee "${SOURCES_LIST_PATH}" >/dev/null

    # Add the debsig-verify policy
    ${SUDO} mkdir -p "${DEBSIG_POLICY_DIR}"
    curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
        | ${SUDO} tee "${DEBSIG_POLICY_DIR}/1password.pol" >/dev/null

    ${SUDO} mkdir -p "${DEBSIG_KEYRING_DIR}"
    curl -sS "${KEY_URL}" \
        | ${SUDO} gpg --dearmor --yes --output "${DEBSIG_KEYRING_DIR}/debsig.gpg"
}

function install_op() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi

    setup_repository

    ${SUDO} apt-get update
    ${SUDO} apt-get install -y "${PACKAGES[@]}"
}

function uninstall_op() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi

    ${SUDO} apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
    ${SUDO} rm -f "${KEYRING_PATH}" "${SOURCES_LIST_PATH}"
    ${SUDO} rm -rf "${DEBSIG_POLICY_DIR}" "${DEBSIG_KEYRING_DIR}"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_op
fi
