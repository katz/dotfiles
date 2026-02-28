# shunk031/dotfiles 調査メモ

参考にした dotfiles リポジトリの設計・実装の詳細メモ。

- 調査日: 2026-02-28
- 対象: https://github.com/shunk031/dotfiles

---

## 概要

chezmoi をベースに Rust 製ツールを中心に組み合わせた dotfiles。
macOS (Apple Silicon)、Ubuntu Desktop、Ubuntu Server の 3 環境に対応している。
CI で実際のセットアップを macOS/Ubuntu 両方で自動テストしている。

---

## ツールスタック

| ツール | 役割 |
|--------|------|
| chezmoi | dotfiles 管理 |
| sheldon | zsh プラグインマネージャ（Rust 製） |
| starship | プロンプト・サーバー用（Rust 製） |
| powerlevel10k | プロンプト・クライアント用 |
| mise | 多言語バージョン管理（Rust 製） |
| age | 秘密鍵・SSH キーの暗号化 |

mise でほぼすべてのツールを管理している（go, node, rust, python, aws-cli, claude-code, codex 等）。

---

## 対応環境

`system` という独自変数で client/server を区別している。

| 環境 | system | プロンプト |
|------|--------|-----------|
| macOS Apple Silicon | client（自動設定） | powerlevel10k |
| Ubuntu Desktop | client（対話式で選択） | powerlevel10k |
| Ubuntu Server | server（対話式で選択） | starship |

`.chezmoi.yaml.tmpl` で初回に `system` を確定させ、以降すべてのテンプレートがこの変数で分岐する。

```yaml
{{- $system := "" -}}
{{- if eq .chezmoi.os "darwin" -}}
{{-   $system = "client" -}}
{{- else -}}
{{-   $system = promptString "System (client or server)" -}}
{{- end -}}
```

---

## ディレクトリ構成

```
dotfiles/
├── .chezmoiroot          # "home" と記述
├── Makefile              # chezmoi 操作のショートカット
├── setup.sh              # ワンライナー用エントリポイント
├── Dockerfile            # Ubuntu テスト環境
├── home/                 # chezmoi のソースルート
│   ├── .chezmoi.yaml.tmpl
│   ├── .chezmoiexternal.yaml.tmpl  # フォント・外部リソース
│   ├── .chezmoiignore              # OS別の除外設定
│   ├── .chezmoiscripts/            # セットアップスクリプト
│   ├── .chezmoitemplates/          # 再利用テンプレート
│   ├── dot_config/                 # ~/.config 以下の設定
│   ├── dot_mise/config.toml        # mise グローバル設定
│   ├── dot_zshrc
│   ├── dot_zprofile
│   ├── private_dot_ssh/            # SSH 設定（秘密鍵は age 暗号化）
│   └── private_dot_gnupg/          # GPG 設定（鍵は age 暗号化）
├── install/                        # OS別インストールスクリプト
│   ├── common/
│   ├── macos/common/
│   └── ubuntu/
├── tests/                          # Bats テスト
│   ├── files/                      # dotfiles 展開後の存在確認
│   └── install/                    # install/ スクリプトのユニットテスト
└── scripts/
    ├── run_unit_test.sh            # kcov 付きテスト実行
    └── run_benchmark.sh            # zsh 起動速度計測
```

---

## インストールフロー

### ワンライナー

```bash
bash -c "$(curl -fsLS http://shunk031.me/dotfiles/setup.sh)"
```

### setup.sh の処理

1. OS 判定 → macOS なら Homebrew をインストール
2. sudo を維持（macOS はキーチェーン経由、Linux は `sudo -v` ループ）
3. chezmoi バイナリをダウンロード
4. `chezmoi init` でリポジトリをクローン
5. CI 環境では暗号化ファイル（`encrypted_*.age`）を削除
6. `chezmoi apply` で dotfiles を展開
7. プライベート dotfiles リポジトリも SSH 経由で適用
8. chezmoi バイナリを削除（以降は mise 経由で使う）

### chezmoiscripts の実行順序

chezmoi は `before_` → dotfiles 展開 → `after_`（または無印）の順に実行する。

```
before: common/run_once_before_01-decrypt-private-key.sh.tmpl  # age 秘密鍵の復号
before: macos/run_once_before_01-prepare-system.sh.tmpl        # ARM64 準備
before: macos/run_once_before_02-install-command-line-tool.sh  # Xcode CLT
before: macos/run_once_before_03-install-brew.sh.tmpl          # Homebrew
        → dotfiles 展開
after:  common/run_once_after_01-install-mise.sh.tmpl          # mise
after:  common/run_once_after_02-install-sheldon.sh.tmpl       # sheldon
after:  macos/run_once_08-install-tmux.sh.tmpl
after:  macos/run_once_10-install-docker.sh.tmpl
after:  macos/run_once_50-install-misc.sh.tmpl                 # brew/cask 一括
after:  macos/run_once_99-install-defaults.sh.tmpl             # macOS defaults
```

---

## install/ と .chezmoiscripts/ の関係

install/ のスクリプトを chezmoi テンプレートから `{{ include }}` で読み込む設計。

```
install/common/mise.sh
    ↓ テンプレートで include
home/.chezmoiscripts/common/run_once_after_01-install-mise.sh.tmpl
```

メリット:
- `bash install/common/mise.sh` で単体実行・手動テストができる
- Bats テストは chezmoi を通さず `install/` を直接テストできる
- chezmoi スクリプトには制御ロジックのみ残る

---

## chezmoi テンプレートの工夫

### include で設定ファイルを組み立てる

tmux の設定を OS/system 別に分割して include で合成している。

```
{{ include "dot_tmux.conf.d/common.conf" }}
{{ if eq .system "client" -}}
{{   include "dot_tmux.conf.d/system/client.conf" }}
{{   if eq .chezmoi.os "darwin" -}}
{{     include "dot_tmux.conf.d/os/macos.conf" }}
{{   end -}}
{{ end -}}
```

sheldon のプラグイン設定も同様に `common.toml` + OS/system 別 toml を合成する。

### symlink_ で編集を即時反映

`symlink_config.toml.tmpl` の中身をソースパスにすることで、`chezmoi cd` で編集した内容が適用なしで即座に有効になる。

```
# dot_config/mise/symlink_config.toml.tmpl の内容
{{ .chezmoi.sourceDir }}/dot_mise/config.toml
```

### .chezmoiignore で OS別に除外

`.chezmoiignore` をテンプレートにして、OS/system ごとに不要なファイルを動的に除外している。

```
{{ template "chezmoiignore.d/common" . }}
{{ if eq .chezmoi.os "darwin" -}}
{{   template "chezmoiignore.d/macos" . }}
{{ else if eq .chezmoi.os "linux" -}}
{{   template "chezmoiignore.d/ubuntu/common" . }}
{{   if eq .system "client" -}}
{{     template "chezmoiignore.d/ubuntu/client" . }}
{{   end -}}
{{ end -}}
```

### age による秘密情報の暗号化

SSH 秘密鍵・GPG 鍵・VPN 認証情報を age で暗号化してリポジトリに含めている。
`run_once_before_01-decrypt-private-key.sh.tmpl` が最初に秘密鍵を復号し、以降の処理で使う。

---

## CI/CD

4 つのワークフローで品質を担保している。

| ワークフロー | 内容 |
|---|---|
| `test.yaml` | Bats ユニットテスト（ubuntu-latest, macos-14 × client/server） |
| `macos.yaml` | macOS 実機でフルセットアップ + zsh 速度ベンチマーク |
| `ubuntu.yaml` | Ubuntu Docker コンテナでフルセットアップ |
| `remote.yaml` | 週次で公開 URL からのワンライナーインストールを検証 |

`macos.yaml` と `ubuntu.yaml` は実際に `setup.sh` を実行してセットアップが通ることを確認している。

### ベンチマーク

zsh の起動速度を毎 CI で計測し、別リポジトリ（`my-dotfiles-benchmarks`）に継続記録している。前回比 150% を超えると警告が出る。

---

## Bats テストの構造

```
tests/
├── files/             # dotfiles 展開後のファイル存在確認（smoke test）
└── install/           # install/ スクリプトのユニットテスト
    ├── common/mise.bats
    ├── macos/common/brew.bats, docker.bats, ...
    └── ubuntu/common/misc.bats, tmux.bats, ...
```

各テストは `setup()` / `teardown()` でクリーンな状態を保つ。
kcov でカバレッジを計測し Codecov にアップロードしている。

```bash
@test "[common] mise" {
    DOTFILES_DEBUG=1 bash "${SCRIPT_PATH}"   # インストール実行
    [ -x "$(command -v mise)" ]              # コマンドとして使えるか確認
}
```

---

## 参考にしたい点（自分の dotfiles への応用）

- `system` 変数で client/server を区別する設計（今は isLinux のみで粗い）
- `include` で設定ファイルを組み立てる方法（tmux, sheldon など）
- `symlink_` で mise config を即時反映する手法
- `.chezmoiignore` をテンプレート化して OS別に不要ファイルを除外する
- `run_once_before_` / `run_once_after_` の順序制御を明示する
- Bats テストで install/ スクリプトをユニットテストする構成
- age で SSH 鍵・GPG 鍵を暗号化してリポジトリに含める
