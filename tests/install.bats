#!/usr/bin/env bats

@test "install/ubuntu/packages.sh is executable" {
  [ -x "install/ubuntu/packages.sh" ]
}

@test "install/alpine/packages.sh is executable" {
  [ -x "install/alpine/packages.sh" ]
}

@test "scripts/setup.sh is executable" {
  [ -x "scripts/setup.sh" ]
}

@test "scripts/setup.sh has valid shebang" {
  head -1 scripts/setup.sh | grep -q "^#!/"
}

@test ".chezmoiroot contains 'home'" {
  grep -q "^home$" .chezmoiroot
}

@test "home/.chezmoi.toml.tmpl exists" {
  [ -f "home/.chezmoi.toml.tmpl" ]
}
