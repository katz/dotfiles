#!/bin/bash
# shellcheck shell=bash
set -Eeuo pipefail

#
#  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗
#  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝
#  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗
#  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║
#  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║
#  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝
#
#  https://github.com/katz/dotfiles
#

readonly GITHUB_USER="katz"
readonly DOTFILES_REPO="dotfiles"

# Branch to use for chezmoi init (defaults to repo default branch).
# Set via env var to test a specific branch in CI.
DOTFILES_BRANCH="${DOTFILES_BRANCH:-}"
readonly DOTFILES_BRANCH

CHEZMOI_BIN=""

# ---------------------------------------------------------------------------
# Environment detection
# ---------------------------------------------------------------------------

is_ci() {
    [ "${CI:-}" = "true" ]
}

is_tty() {
    [ -t 1 ]
}

is_not_tty() {
    ! is_tty
}

is_ci_or_not_tty() {
    is_ci || is_not_tty
}

# ---------------------------------------------------------------------------
# Trap management
# ---------------------------------------------------------------------------

_at_exit_handlers=()

at_exit() {
    local handler="$1"
    _at_exit_handlers+=("${handler}")
}

_run_at_exit_handlers() {
    local exit_code=$?
    for handler in "${_at_exit_handlers[@]+"${_at_exit_handlers[@]}"}"; do
        eval "${handler}" || true
    done
    exit "${exit_code}"
}

trap _run_at_exit_handlers EXIT

# ---------------------------------------------------------------------------
# sudo keepalive
# ---------------------------------------------------------------------------

keepalive_sudo_linux() {
    if is_ci; then
        return
    fi
    sudo -v
    while true; do
        sudo -v
        sleep 60
    done &
    at_exit "kill $! 2>/dev/null || true"
}

keepalive_sudo_macos() {
    if is_ci; then
        return
    fi

    local askpass_script
    askpass_script="$(mktemp)"
    at_exit "rm -f '${askpass_script}'"

    cat > "${askpass_script}" <<'ASKPASS'
#!/bin/bash
osascript -e 'Tell application "System Events" to display dialog "Password:" default answer "" with hidden answer' \
          -e 'text returned of result' 2>/dev/null
ASKPASS
    chmod +x "${askpass_script}"

    sudo -v
    export SUDO_ASKPASS="${askpass_script}"
    while true; do
        sudo -A -v
        sleep 60
    done &
    at_exit "kill $! 2>/dev/null || true"
}

keepalive_sudo() {
    case "$(uname -s)" in
        Darwin) keepalive_sudo_macos ;;
        Linux)  keepalive_sudo_linux ;;
    esac
}

# ---------------------------------------------------------------------------
# OS initialization
# ---------------------------------------------------------------------------

initialize_os_macos() {
    # Install Homebrew if not present
    if ! command -v brew >/dev/null 2>&1; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi

    # Set up Homebrew environment for Apple Silicon
    if [ -x "/opt/homebrew/bin/brew" ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
}

initialize_os_env() {
    case "$(uname -s)" in
        Darwin) initialize_os_macos ;;
        Linux)  ;;
    esac
}

# ---------------------------------------------------------------------------
# chezmoi
# ---------------------------------------------------------------------------

_cleanup_chezmoi_bin() {
    if [ -n "${CHEZMOI_BIN}" ] && [ -f "${CHEZMOI_BIN}" ]; then
        rm -f "${CHEZMOI_BIN}"
    fi
}

run_chezmoi() {
    local no_tty_flag=""
    if is_ci_or_not_tty; then
        no_tty_flag="--no-tty"
    fi

    if ! command -v chezmoi >/dev/null 2>&1; then
        echo "Installing chezmoi..."
        CHEZMOI_BIN="$(mktemp)"
        at_exit "_cleanup_chezmoi_bin"
        sh -c "$(curl -fsSL get.chezmoi.io)" -- -b "$(dirname "${CHEZMOI_BIN}")" -t "${CHEZMOI_BIN##*/}"
        chmod +x "${CHEZMOI_BIN}"
    else
        CHEZMOI_BIN="$(command -v chezmoi)"
    fi

    local branch_flag=""
    if [ -n "${DOTFILES_BRANCH}" ]; then
        branch_flag="--branch ${DOTFILES_BRANCH}"
    fi

    # shellcheck disable=SC2086
    "${CHEZMOI_BIN}" init ${no_tty_flag} ${branch_flag} "https://github.com/${GITHUB_USER}/${DOTFILES_REPO}.git"

    # shellcheck disable=SC2086
    "${CHEZMOI_BIN}" apply ${no_tty_flag}
}

# ---------------------------------------------------------------------------
# Restart shell
# ---------------------------------------------------------------------------

restart_shell() {
    if is_ci_or_not_tty; then
        return
    fi
    echo ""
    echo "Restarting shell..."
    exec "${SHELL}" -l
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    echo "Setting up dotfiles for ${GITHUB_USER}..."

    keepalive_sudo

    initialize_os_env

    run_chezmoi

    restart_shell

    echo "Done!"
}

main "$@"
