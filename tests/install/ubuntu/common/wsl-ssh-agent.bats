#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/common/wsl-ssh-agent.sh"

function setup() {
    if ! grep -qi microsoft /proc/sys/kernel/osrelease 2>/dev/null; then
        skip "wsl-ssh-agent requires WSL environment"
    fi
    source "${SCRIPT_PATH}"
}

function teardown() {
    run uninstall_wsl_ssh_agent
}

@test "[ubuntu-common] NPIPERELAY_VERSION is defined" {
    [ -n "${NPIPERELAY_VERSION}" ]
}

@test "[ubuntu-common] NPIPERELAY_URL contains correct version" {
    [[ "${NPIPERELAY_URL}" == *"v${NPIPERELAY_VERSION}"* ]]
}

@test "[ubuntu-common] NPIPERELAY_DEST points to local bin" {
    [[ "${NPIPERELAY_DEST}" == *"/.local/bin/npiperelay.exe" ]]
}

@test "[ubuntu-common] install_wsl_ssh_agent function exists" {
    declare -f install_wsl_ssh_agent
}

@test "[ubuntu-common] uninstall_wsl_ssh_agent function exists" {
    declare -f uninstall_wsl_ssh_agent
}

@test "[ubuntu-common] npiperelay.exe is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "${HOME}/.local/bin/npiperelay.exe" ]
}

@test "[ubuntu-common] socat is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"

    [ -x "$(command -v socat)" ]
}
