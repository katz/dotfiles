#!/usr/bin/env bats

# bats file_tags=common

@test "[common] dotfiles are applied" {
    files=(
        "${HOME}/.zshrc"
        "${HOME}/.gitconfig"
        "${HOME}/.gitignore_global"
    )
    for file in "${files[@]}"; do
        echo "Checking ${file}"
        [ -f "${file}" ]
    done
}
