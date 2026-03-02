#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function get_time_command() {
    case "$(uname -s | tr '[:upper:]' '[:lower:]')" in
    darwin)
        echo -n "gtime"
        ;;
    linux)
        echo -n "/usr/bin/time"
        ;;
    esac
}

function measure_startup_time() {
    local result_file=$1
    local time_cmd
    time_cmd="$(get_time_command)"
    "${time_cmd}" --format="%e" --output="${result_file}" zsh -i -c exit 2>/dev/null
}

function main() {
    local tmp_dir
    tmp_dir="$(mktemp -d)"
    trap 'rm -rf "${tmp_dir}"' EXIT

    # 初回計測
    measure_startup_time "${tmp_dir}/initial.txt"

    # 10 回計測
    for i in $(seq 1 10); do
        measure_startup_time "${tmp_dir}/run-${i}.txt"
    done

    local initial_time average_time
    initial_time=$(cat "${tmp_dir}/initial.txt")
    # shellcheck disable=SC2086
    average_time=$(cat ${tmp_dir}/run-*.txt | awk '{ total += $1 } END { print total/NR }')

    cat <<EOJ
[
    {
        "name": "zsh average startup time",
        "unit": "Second",
        "value": ${average_time}
    },
    {
        "name": "zsh initial startup time",
        "unit": "Second",
        "value": ${initial_time}
    }
]
EOJ
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi
