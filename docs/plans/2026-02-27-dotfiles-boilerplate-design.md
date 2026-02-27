# dotfiles ボイラープレート 設計ドキュメント

- 作成日: 2026-02-27
- ステータス: 承認済み

## 概要

[shunk031/dotfiles](https://github.com/shunk031/dotfiles) を参考に、chezmoi ベースの dotfiles リポジトリを構築する。macOS (Apple Silicon)、Ubuntu Server、Alpine Linux (Raspberry Pi) の3環境に対応する。

## 管理ツール

**chezmoi** を採用する。

- `.chezmoiroot = "home"` により、実際の設定ファイルは `home/` 配下に集約する
- ワンライナーでのセットアップを提供する

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init katz --apply
```

## 対応環境

| 環境 | 用途 |
|------|------|
| macOS Apple Silicon | メイン開発環境 |
| Ubuntu Server | Linux サーバー |
| Alpine Linux | Raspberry Pi（自宅） |

## OS 検出

`.chezmoi.toml.tmpl` で以下の2変数のみを定義する。Linux ディストロ間の差異（apt vs apk）はスクリプト内でパッケージマネージャーを検出して吸収する。

```toml
{{- $name := promptStringOnce . "name" "Your name" -}}
{{- $email := promptStringOnce . "email" "Your email" -}}

[data]
  name = {{ $name | quote }}
  email = {{ $email | quote }}
  isAppleSiliconMac = {{ and (eq .chezmoi.os "darwin") (eq .chezmoi.arch "arm64") }}
  isLinux = {{ eq .chezmoi.os "linux" }}
```

スクリプト内でのパッケージマネージャー検出例：

```sh
{{- if .isLinux }}
if command -v apt-get &>/dev/null; then
  apt-get install -y zsh git
elif command -v apk &>/dev/null; then
  apk add --no-cache zsh git
fi
{{- end }}
```

## 管理対象

- Zsh / シェル設定（.zshrc、エイリアス、関数）
- Git 設定（.gitconfig、.gitignore_global）
- エディタ設定（Neovim、VS Code、Zed）
- ターミナル設定（tmux、その他）

## ディレクトリ構造

```
dotfiles/
├── home/                          # chezmoiルート
│   ├── .chezmoiscripts/
│   │   ├── macos/
│   │   │   ├── run_once_10-install-homebrew.sh.tmpl
│   │   │   └── run_once_20-install-packages.sh.tmpl
│   │   ├── linux/
│   │   │   └── run_once_10-install-packages.sh.tmpl
│   │   └── run_once_00-common.sh.tmpl
│   ├── dot_zshrc.tmpl
│   ├── dot_gitconfig.tmpl
│   └── dot_config/
│       ├── sheldon/
│       ├── starship/
│       ├── tmux/
│       └── nvim/
├── install/                       # 個別アプリのインストールスクリプト
│   ├── macos/
│   │   └── common/
│   │       ├── homebrew.sh
│   │       └── packages.sh
│   ├── ubuntu/
│   │   └── packages.sh
│   └── alpine/
│       └── packages.sh
├── tests/                         # Bats テスト
│   └── install.bats
├── scripts/
│   └── setup.sh                   # ワンライナー用エントリポイント
├── .github/
│   └── workflows/
│       ├── test.yml               # Bats + Docker（Ubuntu/Alpine）
│       └── lint.yml               # shellcheck
├── .chezmoiroot                   # "home" と記載
├── .editorconfig
└── .gitignore
```

## CI/CD

### test.yml

Docker コンテナを使って以下の環境で Bats テストを実行する。

| 環境 | イメージ |
|------|---------|
| Ubuntu | `ubuntu:latest` |
| Alpine | `alpine:latest`（x86_64 で代替。実機は ARM だが基本的な動作確認として許容） |

### lint.yml

shellcheck ですべてのシェルスクリプトを静的解析する。

## 参考

- [shunk031/dotfiles](https://github.com/shunk031/dotfiles)
- [chezmoi 公式ドキュメント](https://www.chezmoi.io/)
- [Bats](https://github.com/bats-core/bats-core)
