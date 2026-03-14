# CLAUDE.md

## 知識の記録

- 会話の中でプロジェクト固有の知識が出た場合は、記録を提案すること
  - 規約・ルール・設計判断 → このファイル（CLAUDE.md）への追記
  - 複数ステップの手順や繰り返し使うタスク → スキル化

## Testing

- `install/` 配下にスクリプトを追加・変更したら、対応する bats テストを `tests/install/` 配下に必ず作成・更新すること
- テストのディレクトリ構造は `install/` のディレクトリ構造と一致させる（例: `install/common/foo.sh` → `tests/install/common/foo.bats`）
- 既存のテストファイルを参考にしてパターンを合わせること

## Bash Scripts

- `.sh` ファイルには実行権限（755）を付与する
- Shebang: `#!/usr/bin/env bash`
- エラーハンドリング: `set -Eeuo pipefail`
- デバッグ: `if [ "${DOTFILES_DEBUG:-}" ]; then set -x; fi` を先頭に入れる
- 定数は `readonly` で定義する
- 関数内の変数は `local` を使う
- 関数名のプレフィックス規則:
  - `install_` — インストール処理
  - `uninstall_` — アンインストール処理（テストの `teardown()` で使うため必須）
  - `is_` — 判定処理
  - `setup_` — セットアップ処理

## Install Scripts

- インストールロジックは `install/` 配下に独立したシェルスクリプトとして配置する（`source` 可能な形にする）
  - `install/common/` — 全環境共通
  - `install/macos/` — macOS のみ
  - `install/ubuntu/` — Ubuntu のみ
- chezmoi のスクリプト（`home/.chezmoiscripts/`）からは `{{ include "../install/common/xxx.sh" }}` で取り込む
- スクリプトは直接実行と `source` の両方に対応するため、末尾に `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then ... fi` パターンを使う

## Chezmoi Scripts

- `home/.chezmoiscripts/` 配下のスクリプトは番号付きの命名で実行順序を制御する
  - `run_once_before_01-*` — 前提条件のインストール
  - `run_once_after_01-*` 〜 `run_once_after_03-*` — コアツールのインストール
  - `run_onchange_after_*` — 内容変更時に再実行が必要なもの（プラグインリストなど）
