# dotfiles ボイラープレート 実装計画

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** chezmoi ベースの dotfiles リポジトリのボイラープレートを構築する

**Architecture:** `.chezmoiroot = "home"` で設定ファイルを `home/` に集約し、OS 検出は `isAppleSiliconMac` / `isLinux` の2変数のみで行う。Linux 内のディストロ差異（apt vs apk）はスクリプト内でパッケージマネージャーを検出して吸収する。

**Tech Stack:** chezmoi, Zsh, Bats (bash testing), shellcheck, GitHub Actions, Docker

---

### Task 1: chezmoi ルート設定

**Files:**
- Create: `.chezmoiroot`
- Create: `home/.chezmoi.toml.tmpl`

**Step 1: .chezmoiroot を作成**

```bash
echo "home" > .chezmoiroot
```

**Step 2: home ディレクトリと chezmoi 設定テンプレートを作成**

`home/.chezmoi.toml.tmpl` を以下の内容で作成する：

```toml
{{- $name := promptStringOnce . "name" "Your name" -}}
{{- $email := promptStringOnce . "email" "Your email" -}}

[data]
  name = {{ $name | quote }}
  email = {{ $email | quote }}
  isAppleSiliconMac = {{ and (eq .chezmoi.os "darwin") (eq .chezmoi.arch "arm64") }}
  isLinux = {{ eq .chezmoi.os "linux" }}
```

**Step 3: 動作確認**

```bash
chezmoi doctor
```

Expected: chezmoi が `.chezmoiroot` を認識し、`home/` をソースディレクトリとして使用していること

**Step 4: コミット**

```bash
git add .chezmoiroot home/.chezmoi.toml.tmpl
git commit -m "chore: initialize chezmoi with home/ as root"
```

---

### Task 2: Zsh 設定テンプレート（最小構成）

**Files:**
- Create: `home/dot_zshrc.tmpl`

**Step 1: 最小限の .zshrc テンプレートを作成**

`home/dot_zshrc.tmpl` を以下の内容で作成する：

```sh
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

# 追加の設定はここに記述する
```

**Step 2: chezmoi でテンプレートが認識されることを確認**

```bash
chezmoi cat ~/.zshrc
```

Expected: テンプレートが展開されたファイル内容が表示されること

**Step 3: コミット**

```bash
git add home/dot_zshrc.tmpl
git commit -m "feat: add minimal zsh configuration template"
```

---

### Task 3: Git 設定テンプレート

**Files:**
- Create: `home/dot_gitconfig.tmpl`
- Create: `home/dot_gitignore_global`

**Step 1: .gitconfig テンプレートを作成**

`home/dot_gitconfig.tmpl` を以下の内容で作成する：

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

**Step 2: グローバル .gitignore を作成**

`home/dot_gitignore_global` を以下の内容で作成する：

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

**Step 3: コミット**

```bash
git add home/dot_gitconfig.tmpl home/dot_gitignore_global
git commit -m "feat: add git configuration templates"
```

---

### Task 4: インストールスクリプト（macOS）

**Files:**
- Create: `install/macos/common/homebrew.sh`
- Create: `install/macos/common/packages.sh`

**Step 1: Homebrew インストールスクリプトを作成**

`install/macos/common/homebrew.sh` を以下の内容で作成する：

```sh
#!/usr/bin/env bash
set -euo pipefail

if command -v brew &>/dev/null; then
  echo "Homebrew is already installed"
  exit 0
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Step 2: パッケージインストールスクリプトを作成**

`install/macos/common/packages.sh` を以下の内容で作成する：

```sh
#!/usr/bin/env bash
set -euo pipefail

# 最低限必要なパッケージ（Brewfile は別途管理）
brew install \
  chezmoi \
  git \
  zsh \
  sheldon \
  starship
```

**Step 3: 実行権限を付与**

```bash
chmod +x install/macos/common/homebrew.sh
chmod +x install/macos/common/packages.sh
```

**Step 4: コミット**

```bash
git add install/macos/
git commit -m "feat: add macOS install scripts"
```

---

### Task 5: インストールスクリプト（Linux）

**Files:**
- Create: `install/ubuntu/packages.sh`
- Create: `install/alpine/packages.sh`

**Step 1: Ubuntu パッケージインストールスクリプトを作成**

`install/ubuntu/packages.sh` を以下の内容で作成する：

```sh
#!/usr/bin/env bash
set -euo pipefail

apt-get update
apt-get install -y \
  git \
  zsh \
  curl \
  wget \
  unzip
```

**Step 2: Alpine パッケージインストールスクリプトを作成**

`install/alpine/packages.sh` を以下の内容で作成する：

```sh
#!/bin/sh
set -eu

apk update
apk add --no-cache \
  git \
  zsh \
  curl \
  wget \
  unzip \
  bash
```

**Step 3: 実行権限を付与**

```bash
chmod +x install/ubuntu/packages.sh
chmod +x install/alpine/packages.sh
```

**Step 4: コミット**

```bash
git add install/ubuntu/ install/alpine/
git commit -m "feat: add Linux install scripts"
```

---

### Task 6: chezmoi スクリプト（macOS）

**Files:**
- Create: `home/.chezmoiscripts/macos/run_once_10-install-homebrew.sh.tmpl`
- Create: `home/.chezmoiscripts/macos/run_once_20-install-packages.sh.tmpl`

**Step 1: Homebrew インストール chezmoi スクリプトを作成**

`home/.chezmoiscripts/macos/run_once_10-install-homebrew.sh.tmpl` を以下の内容で作成する：

```sh
{{- if .isAppleSiliconMac }}
#!/usr/bin/env bash
set -euo pipefail

if command -v brew &>/dev/null; then
  echo "Homebrew is already installed"
  exit 0
fi

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
{{- end }}
```

**Step 2: パッケージインストール chezmoi スクリプトを作成**

`home/.chezmoiscripts/macos/run_once_20-install-packages.sh.tmpl` を以下の内容で作成する：

```sh
{{- if .isAppleSiliconMac }}
#!/usr/bin/env bash
set -euo pipefail

brew install chezmoi git zsh sheldon starship
{{- end }}
```

**Step 3: コミット**

```bash
git add home/.chezmoiscripts/
git commit -m "feat: add chezmoi run_once scripts for macOS"
```

---

### Task 7: chezmoi スクリプト（Linux）

**Files:**
- Create: `home/.chezmoiscripts/linux/run_once_10-install-packages.sh.tmpl`

**Step 1: Linux パッケージインストール chezmoi スクリプトを作成**

`home/.chezmoiscripts/linux/run_once_10-install-packages.sh.tmpl` を以下の内容で作成する：

```sh
{{- if .isLinux }}
#!/bin/sh
set -eu

if command -v apt-get &>/dev/null; then
  apt-get update
  apt-get install -y git zsh curl wget unzip
elif command -v apk &>/dev/null; then
  apk update
  apk add --no-cache git zsh curl wget unzip bash
fi
{{- end }}
```

**Step 2: コミット**

```bash
git add home/.chezmoiscripts/linux/
git commit -m "feat: add chezmoi run_once scripts for Linux"
```

---

### Task 8: セットアップスクリプト（ワンライナー用）

**Files:**
- Create: `scripts/setup.sh`

**Step 1: setup.sh を作成**

`scripts/setup.sh` を以下の内容で作成する：

```sh
#!/bin/sh
set -eu

GITHUB_USER="katz"

# chezmoi がなければインストール
if ! command -v chezmoi &>/dev/null; then
  sh -c "$(curl -fsLS get.chezmoi.io)"
fi

# dotfiles を適用
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

---

### Task 9: Bats テスト

**Files:**
- Create: `tests/install.bats`

**Step 1: Bats テストを作成**

`tests/install.bats` を以下の内容で作成する：

```bash
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
```

**Step 2: コミット**

```bash
git add tests/install.bats
git commit -m "test: add bats tests for install scripts"
```

---

### Task 10: shellcheck lint ワークフロー

**Files:**
- Create: `.github/workflows/lint.yml`

**Step 1: lint.yml を作成**

`.github/workflows/lint.yml` を以下の内容で作成する：

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
        uses: ludeeus/action-shellcheck@master
        with:
          scandir: "."
          severity: warning
```

**Step 2: コミット**

```bash
git add .github/workflows/lint.yml
git commit -m "ci: add shellcheck lint workflow"
```

---

### Task 11: Bats テスト CI ワークフロー

**Files:**
- Create: `.github/workflows/test.yml`

**Step 1: test.yml を作成**

`.github/workflows/test.yml` を以下の内容で作成する：

```yaml
name: Test

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test-ubuntu:
    runs-on: ubuntu-latest
    container:
      image: ubuntu:latest
    steps:
      - uses: actions/checkout@v4

      - name: Install bats
        run: |
          apt-get update
          apt-get install -y bats

      - name: Run tests
        run: bats tests/

  test-alpine:
    runs-on: ubuntu-latest
    container:
      image: alpine:latest
    steps:
      - uses: actions/checkout@v4

      - name: Install bats
        run: apk add --no-cache bash bats git

      - name: Run tests
        run: bats tests/
```

**Step 2: コミット**

```bash
git add .github/workflows/test.yml
git commit -m "ci: add bats test workflow for Ubuntu and Alpine"
```

---

### Task 12: 動作確認

**Step 1: shellcheck をローカルで実行（インストール済みの場合）**

```bash
shellcheck install/**/*.sh scripts/*.sh
```

Expected: エラーなし（または Warning のみ）

**Step 2: chezmoi の設定を検証**

```bash
chezmoi doctor
chezmoi data
```

Expected: `isAppleSiliconMac` と `isLinux` が正しい値で表示されること

**Step 3: ディレクトリ構造を確認**

```bash
find . -not -path './.git/*' -type f | sort
```

Expected: 設計ドキュメントの構造と一致していること

**Step 4: 最終コミット（必要であれば）**

```bash
git status
git log --oneline
```
