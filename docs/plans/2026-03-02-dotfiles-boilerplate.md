# dotfiles boilerplate 実装計画

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** BDD スタイルの Bats テストと zsh 起動速度ベンチマークを備えた chezmoi ベースの dotfiles ボイラープレートを構築する

**Architecture:** shunk031/dotfiles の設計を参考に、「テストが期待値を定義し、install/ スクリプトがその期待値を満たす」BDD フローを採用する。install/ スクリプトは `PACKAGES` 配列・`install_*/uninstall_*` 関数パターンで構造化し、chezmoi スクリプトから `{{ include }}` で埋め込む。`system` 変数（client/server）で macOS・Ubuntu Desktop・Ubuntu Server の 3 環境を制御する。

**Tech Stack:** chezmoi, Bats, shellcheck, GitHub Actions, zsh

---

## ディレクトリ構成（完成形）

```
dotfiles/
├── .chezmoiroot
├── home/
│   ├── .chezmoi.yaml.tmpl
│   ├── .chezmoiignore.tmpl
│   ├── .chezmoiscripts/
│   │   ├── common/
│   │   │   └── run_once_after_01-install-mise.sh.tmpl
│   │   ├── macos/
│   │   │   ├── run_once_before_01-install-homebrew.sh.tmpl
│   │   │   └── run_once_before_02-install-packages.sh.tmpl
│   │   └── ubuntu/
│   │       └── run_once_before_01-install-packages.sh.tmpl
│   ├── dot_gitconfig.tmpl
│   ├── dot_gitignore_global
│   └── dot_zshrc.tmpl
├── install/
│   ├── common/
│   │   └── mise.sh
│   ├── macos/common/
│   │   ├── homebrew.sh
│   │   └── packages.sh
│   └── ubuntu/common/
│       └── packages.sh
├── scripts/
│   └── run_benchmark.sh
├── tests/
│   ├── files/
│   │   └── common.bats
│   └── install/
│       ├── common/
│       │   └── mise.bats
│       ├── macos/common/
│       │   ├── homebrew.bats
│       │   └── packages.bats
│       └── ubuntu/common/
│           └── packages.bats
└── .github/
    └── workflows/
        ├── test.yml
        ├── benchmark.yml
        └── lint.yml
```

---

## install/ スクリプトの共通パターン

すべての install/ スクリプトはこの構造に従う。この構造があることで Bats テストから `source` して `PACKAGES` を検証でき、`uninstall_*` でクリーンアップできる。

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly PACKAGES=(
  foo
  bar
)

function install_xxx() {
    # インストール処理
}

function uninstall_xxx() {
    # アンインストール処理（teardown 用）
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_xxx
fi
```

---

### Task 1: リポジトリ基盤セットアップ

**Files:**
- Create: `.chezmoiroot`
- Create: `home/.chezmoi.yaml.tmpl`

**Step 1: .chezmoiroot を作成**

```
home
```

**Step 2: home/.chezmoi.yaml.tmpl を作成**

macOS は `system = "client"` に自動設定。Ubuntu は対話式で client/server を選択する。

```
{{- $system := "" -}}
{{- if hasKey . "system" -}}
{{-   $system = .system -}}
{{- else if eq .chezmoi.os "darwin" -}}
{{-   $system = "client" -}}
{{- else -}}
{{-   $system = promptStringOnce . "system" "System (client or server)" -}}
{{- end -}}

{{- $name := promptStringOnce . "name" "Your name" -}}
{{- if not $name -}}{{- fail "name is required" -}}{{- end -}}
{{- $email := promptStringOnce . "email" "Your email" -}}
{{- if not $email -}}{{- fail "email is required" -}}{{- end -}}

[data]
  name = {{ $name | quote }}
  email = {{ $email | quote }}
  system = {{ $system | quote }}
  isAppleSiliconMac = {{ and (eq .chezmoi.os "darwin") (eq .chezmoi.arch "arm64") -}}
  isLinux = {{ eq .chezmoi.os "linux" -}}
  isClient = {{ eq $system "client" -}}
  isServer = {{ eq $system "server" -}}
```

**Step 3: コミット**

```bash
git add .chezmoiroot home/.chezmoi.yaml.tmpl
git commit -m "chore: initialize chezmoi with system variable"
```

---

### Task 2: [TEST FIRST] mise テスト

**Files:**
- Create: `tests/install/common/mise.bats`

**Step 1: テストを書く（PACKAGES の期待値定義 → インストール検証）**

```bash
#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/common/mise.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_mise
    PATH=$(getconf PATH)
    export PATH
}

@test "[common] mise script exists" {
    [ -f "${SCRIPT_PATH}" ]
}

@test "[common] mise is available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    export PATH="${HOME}/.local/bin:${PATH}"
    [ -x "$(command -v mise)" ]
}
```

**Step 2: テストが失敗することを確認**

```bash
bats tests/install/common/mise.bats
```

Expected: FAIL（スクリプトが存在しないため）

**Step 3: コミット**

```bash
git add tests/install/common/mise.bats
git commit -m "test: add mise bats test"
```

---

### Task 3: [IMPLEMENT] mise インストールスクリプト

**Files:**
- Create: `install/common/mise.sh`

**Step 1: install/common/mise.sh を作成**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_mise() {
    curl -fsSL https://mise.run | sh
}

function uninstall_mise() {
    rm -f "${HOME}/.local/bin/mise"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_mise
fi
```

**Step 2: 実行権限を付与**

```bash
chmod +x install/common/mise.sh
```

**Step 3: テストがパスすることを確認**

```bash
bats tests/install/common/mise.bats
```

Expected: PASS

**Step 4: コミット**

```bash
git add install/common/mise.sh
git commit -m "feat: add mise install script"
```

---

### Task 4: [TEST FIRST] Homebrew テスト（macOS）

**Files:**
- Create: `tests/install/macos/common/homebrew.bats`

**Step 1: テストを書く**

```bash
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
```

**Step 2: テストが失敗することを確認**

```bash
bats tests/install/macos/common/homebrew.bats
```

Expected: FAIL

**Step 3: コミット**

```bash
git add tests/install/macos/common/homebrew.bats
git commit -m "test: add homebrew bats test"
```

---

### Task 5: [IMPLEMENT] Homebrew インストールスクリプト（macOS）

**Files:**
- Create: `install/macos/common/homebrew.sh`

**Step 1: install/macos/common/homebrew.sh を作成**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

function install_homebrew() {
    if command -v brew >/dev/null 2>&1; then
        echo "Homebrew is already installed"
        return 0
    fi
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_homebrew
fi
```

**Step 2: 実行権限を付与**

```bash
chmod +x install/macos/common/homebrew.sh
```

**Step 3: テストがパスすることを確認**

```bash
bats tests/install/macos/common/homebrew.bats
```

Expected: PASS

**Step 4: コミット**

```bash
git add install/macos/common/homebrew.sh
git commit -m "feat: add homebrew install script"
```

---

### Task 6: [TEST FIRST] macOS パッケージテスト

**Files:**
- Create: `tests/install/macos/common/packages.bats`

**Step 1: テストを書く**

```bash
#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/macos/common/packages.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_packages
}

@test "[macos-common] PACKAGES contains expected tools" {
    expected_packages=(
        sheldon
        starship
    )
    [ "${#PACKAGES[@]}" -eq "${#expected_packages[@]}" ]
    for ((i = 0; i < ${#expected_packages[*]}; ++i)); do
        [ "${PACKAGES[$i]}" = "${expected_packages[$i]}" ]
    done
}

@test "[macos-common] packages are available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    [ -x "$(command -v sheldon)" ]
    [ -x "$(command -v starship)" ]
}
```

**Step 2: テストが失敗することを確認**

```bash
bats tests/install/macos/common/packages.bats
```

Expected: FAIL

**Step 3: コミット**

```bash
git add tests/install/macos/common/packages.bats
git commit -m "test: add macos packages bats test"
```

---

### Task 7: [IMPLEMENT] macOS パッケージインストールスクリプト

**Files:**
- Create: `install/macos/common/packages.sh`

**Step 1: install/macos/common/packages.sh を作成**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly PACKAGES=(
    sheldon
    starship
)

function install_packages() {
    brew install "${PACKAGES[@]}"
}

function uninstall_packages() {
    brew uninstall --ignore-dependencies "${PACKAGES[@]}" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_packages
fi
```

**Step 2: 実行権限を付与**

```bash
chmod +x install/macos/common/packages.sh
```

**Step 3: テストがパスすることを確認**

```bash
bats tests/install/macos/common/packages.bats
```

Expected: PASS

**Step 4: コミット**

```bash
git add install/macos/common/packages.sh
git commit -m "feat: add macos packages install script"
```

---

### Task 8: [TEST FIRST] Ubuntu パッケージテスト

**Files:**
- Create: `tests/install/ubuntu/common/packages.bats`

**Step 1: テストを書く**

```bash
#!/usr/bin/env bats

readonly SCRIPT_PATH="./install/ubuntu/common/packages.sh"

function setup() {
    source "${SCRIPT_PATH}"
}

function teardown() {
    uninstall_packages
}

@test "[ubuntu-common] PACKAGES contains expected tools" {
    expected_packages=(
        curl
        git
        unzip
        wget
        zsh
    )
    [ "${#PACKAGES[@]}" -eq "${#expected_packages[@]}" ]
    for ((i = 0; i < ${#expected_packages[*]}; ++i)); do
        [ "${PACKAGES[$i]}" = "${expected_packages[$i]}" ]
    done
}

@test "[ubuntu-common] packages are available after install" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"
    [ -x "$(command -v git)" ]
    [ -x "$(command -v zsh)" ]
    [ -x "$(command -v curl)" ]
}
```

**Step 2: テストが失敗することを確認**

```bash
bats tests/install/ubuntu/common/packages.bats
```

Expected: FAIL

**Step 3: コミット**

```bash
git add tests/install/ubuntu/common/packages.bats
git commit -m "test: add ubuntu packages bats test"
```

---

### Task 9: [IMPLEMENT] Ubuntu パッケージインストールスクリプト

**Files:**
- Create: `install/ubuntu/common/packages.sh`

**Step 1: install/ubuntu/common/packages.sh を作成**

```bash
#!/usr/bin/env bash
set -euo pipefail

if [ "${DOTFILES_DEBUG:-}" ]; then
    set -x
fi

readonly PACKAGES=(
    curl
    git
    unzip
    wget
    zsh
)

function install_packages() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get update
    ${SUDO} apt-get install -y "${PACKAGES[@]}"
}

function uninstall_packages() {
    local SUDO=""
    if [ "$(id -u)" -ne 0 ]; then
        SUDO="sudo"
    fi
    ${SUDO} apt-get remove -y "${PACKAGES[@]}" 2>/dev/null || true
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    install_packages
fi
```

**Step 2: 実行権限を付与**

```bash
chmod +x install/ubuntu/common/packages.sh
```

**Step 3: テストがパスすることを確認**

```bash
bats tests/install/ubuntu/common/packages.bats
```

Expected: PASS（Docker Ubuntu コンテナ内で実行）

**Step 4: コミット**

```bash
git add install/ubuntu/common/packages.sh
git commit -m "feat: add ubuntu packages install script"
```

---

### Task 10: chezmoi スクリプト

**Files:**
- Create: `home/.chezmoiscripts/common/run_once_after_01-install-mise.sh.tmpl`
- Create: `home/.chezmoiscripts/macos/run_once_before_01-install-homebrew.sh.tmpl`
- Create: `home/.chezmoiscripts/macos/run_once_before_02-install-packages.sh.tmpl`
- Create: `home/.chezmoiscripts/ubuntu/run_once_before_01-install-packages.sh.tmpl`

**Step 1: common/run_once_after_01-install-mise.sh.tmpl を作成**

mise はすべての環境で install 後に入れる（`after_`）。

```
{{ include "../install/common/mise.sh" }}
```

**Step 2: macos/run_once_before_01-install-homebrew.sh.tmpl を作成**

```
{{- if .isAppleSiliconMac }}
{{ include "../install/macos/common/homebrew.sh" }}
{{- end }}
```

**Step 3: macos/run_once_before_02-install-packages.sh.tmpl を作成**

```
{{- if .isAppleSiliconMac }}
{{ include "../install/macos/common/packages.sh" }}
{{- end }}
```

**Step 4: ubuntu/run_once_before_01-install-packages.sh.tmpl を作成**

```
{{- if .isLinux }}
{{ include "../install/ubuntu/common/packages.sh" }}
{{- end }}
```

**Step 5: コミット**

```bash
git add home/.chezmoiscripts/
git commit -m "feat: add chezmoi run_once scripts using include pattern"
```

---

### Task 11: dotfiles テンプレート

**Files:**
- Create: `home/dot_zshrc.tmpl`
- Create: `home/dot_gitconfig.tmpl`
- Create: `home/dot_gitignore_global`

**Step 1: home/dot_zshrc.tmpl を作成**

```
# ~/.zshrc

# XDG Base Directory
export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CACHE_HOME="${HOME}/.cache"

# PATH
export PATH="${HOME}/.local/bin:${PATH}"

{{- if .isAppleSiliconMac }}
# Homebrew (Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"
{{- end }}

# mise
eval "$(mise activate zsh)"

{{- if .isClient }}
# Sheldon (plugin manager)
eval "$(sheldon source)"
{{- end }}

{{- if .isServer }}
# Starship (prompt)
eval "$(starship init zsh)"
{{- end }}
```

**Step 2: home/dot_gitconfig.tmpl を作成**

```toml
[user]
  name = {{ .name }}
  email = {{ .email }}

[core]
  excludesfile = ~/.gitignore_global
  autocrlf = input

[init]
  defaultBranch = main

[pull]
  rebase = true

[push]
  autoSetupRemote = true
```

**Step 3: home/dot_gitignore_global を作成**

```
# macOS
.DS_Store
.AppleDouble
.LSOverride

# Editor
.idea/
*.swp
*.swo
*~

# OS
Thumbs.db
```

**Step 4: コミット**

```bash
git add home/dot_zshrc.tmpl home/dot_gitconfig.tmpl home/dot_gitignore_global
git commit -m "feat: add dotfile templates"
```

---

### Task 12: .chezmoiignore.tmpl

**Files:**
- Create: `home/.chezmoiignore.tmpl`

**Step 1: home/.chezmoiignore.tmpl を作成**

OS/system に不要なスクリプトを除外する。

```
{{- if not .isAppleSiliconMac }}
.chezmoiscripts/macos
{{- end }}

{{- if not .isLinux }}
.chezmoiscripts/ubuntu
{{- end }}
```

**Step 2: コミット**

```bash
git add home/.chezmoiignore.tmpl
git commit -m "chore: add chezmoiignore template for OS-specific exclusions"
```

---

### Task 13: tests/files/common.bats（dotfiles 展開後の確認）

**Files:**
- Create: `tests/files/common.bats`

**Step 1: テストを作成**

chezmoi apply 後のファイル存在を確認する smoke test。

```bash
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
```

**Step 2: コミット**

```bash
git add tests/files/common.bats
git commit -m "test: add smoke test for dotfiles placement"
```

---

### Task 14: ベンチマークスクリプト

**Files:**
- Create: `scripts/run_benchmark.sh`

**Step 1: scripts/run_benchmark.sh を作成**

zsh の起動時間を計測して JSON で出力する。初回 1 回 + 10 回の平均を計測する。

```bash
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
```

**Step 2: 実行権限を付与**

```bash
chmod +x scripts/run_benchmark.sh
```

**Step 3: コミット**

```bash
git add scripts/run_benchmark.sh
git commit -m "feat: add zsh startup time benchmark script"
```

---

### Task 15: GitHub Actions - test.yml

**Files:**
- Create: `.github/workflows/test.yml`

**Step 1: test.yml を作成**

macOS と Ubuntu それぞれで Bats テストを実行する。matrix で client/server を切り替える。

```yaml
name: Test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    strategy:
      fail-fast: false
      matrix:
        include:
          - os: ubuntu-latest
            system: client
          - os: ubuntu-latest
            system: server
          - os: macos-14
            system: client

    runs-on: ${{ matrix.os }}

    steps:
      - uses: actions/checkout@v4

      - name: Install bats (Ubuntu)
        if: runner.os == 'Linux'
        env:
          DEBIAN_FRONTEND: noninteractive
        run: |
          sudo apt-get update
          sudo apt-get install -y bats

      - name: Install bats (macOS)
        if: runner.os == 'macOS'
        run: brew install bats-core

      - name: Run install tests (common)
        run: bats tests/install/common/

      - name: Run install tests (Ubuntu)
        if: runner.os == 'Linux'
        run: bats tests/install/ubuntu/

      - name: Run install tests (macOS)
        if: runner.os == 'macOS'
        run: bats tests/install/macos/
```

**Step 2: コミット**

```bash
git add .github/workflows/test.yml
git commit -m "ci: add bats test workflow"
```

---

### Task 16: GitHub Actions - benchmark.yml

**Files:**
- Create: `.github/workflows/benchmark.yml`

**Step 1: benchmark.yml を作成**

macOS で zsh の起動速度を計測して CI のサマリーに出力する。

```yaml
name: Benchmark

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  benchmark:
    runs-on: macos-14

    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: brew install gnu-time chezmoi

      - name: Apply dotfiles
        run: chezmoi init --apply --source="${GITHUB_WORKSPACE}/home"

      - name: Run benchmark
        run: scripts/run_benchmark.sh | tee benchmark-result.json

      - name: Show benchmark result
        run: cat benchmark-result.json

      - name: Upload benchmark result
        uses: actions/upload-artifact@v4
        with:
          name: benchmark-result
          path: benchmark-result.json
```

**Step 2: コミット**

```bash
git add .github/workflows/benchmark.yml
git commit -m "ci: add zsh startup time benchmark workflow"
```

---

### Task 17: GitHub Actions - lint.yml

**Files:**
- Create: `.github/workflows/lint.yml`

**Step 1: lint.yml を作成**

```yaml
name: Lint

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  shellcheck:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run shellcheck
        uses: reviewdog/action-shellcheck@v1.32.0
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          reporter: github-check
          pattern: "*.sh"
          exclude: "./.git/*"
```

**Step 2: コミット**

```bash
git add .github/workflows/lint.yml
git commit -m "ci: add shellcheck lint workflow"
```

---

### Task 18: scripts/setup.sh（ワンライナー用）

**Files:**
- Create: `scripts/setup.sh`

**Step 1: scripts/setup.sh を作成**

```bash
#!/bin/sh
set -eu

GITHUB_USER="katz"

if ! command -v chezmoi >/dev/null 2>&1; then
    sh -c "$(curl -fsLS get.chezmoi.io)"
    export PATH="${HOME}/bin:${PATH}"
fi

chezmoi init --apply "${GITHUB_USER}"
```

**Step 2: 実行権限を付与**

```bash
chmod +x scripts/setup.sh
```

**Step 3: コミット**

```bash
git add scripts/setup.sh
git commit -m "feat: add one-liner setup script"
```
