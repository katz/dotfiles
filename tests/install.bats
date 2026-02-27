#!/usr/bin/env bats

REPO_ROOT="$(cd "${BATS_TEST_DIRNAME}/.." && pwd)"

@test "install/ubuntu/packages.sh is executable" {
  [ -x "${REPO_ROOT}/install/ubuntu/packages.sh" ]
}

@test "install/alpine/packages.sh is executable" {
  [ -x "${REPO_ROOT}/install/alpine/packages.sh" ]
}

@test "scripts/setup.sh is executable" {
  [ -x "${REPO_ROOT}/scripts/setup.sh" ]
}

@test "scripts/setup.sh has valid shebang" {
  head -1 "${REPO_ROOT}/scripts/setup.sh" | grep -q "^#!/"
}

@test ".chezmoiroot contains 'home'" {
  grep -q "^home$" "${REPO_ROOT}/.chezmoiroot"
}

@test "home/.chezmoi.toml.tmpl exists" {
  [ -f "${REPO_ROOT}/home/.chezmoi.toml.tmpl" ]
}
