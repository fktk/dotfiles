# install.sh 改善 実装計画

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** `install.sh` を自動検出・ファイル単位シンボリックリンク方式に書き換え、手動メンテナンスを不要にする。

**Architecture:** スクリプトがリポジトリルートのファイル・ディレクトリを自動検出し、ルートファイルは `~/` に、ディレクトリ内ファイルは `~/.config/<dir>/` 下に個別シンボリックリンクを張る。ディレクトリ本体は `mkdir -p` で実体作成する。

**Tech Stack:** Bash (純粋)

---

### Task 1: 自動検出型 install.sh の実装

**Files:**
- Modify: `install.sh`
- Test: `test_install.sh`（一時検証用スクリプト）

- [ ] **Step 1: 既存 install.sh のバックアップ確認**

既存の `install.sh` を確認する（読み込み済みのはず）。

- [ ] **Step 2: 新しい install.sh を実装**

```bash
#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"

# .config 下に配置するディレクトリ群を自動検出
for dir in "$DOTFILES_DIR"/*/; do
    [ -d "$dir" ] || continue

    base=$(basename "$dir")

    # 除外対象
    case "$base" in
        .git|.worktrees) continue ;;
    esac

    target_dir="$CONFIG_DIR/$base"
    mkdir -p "$target_dir"

    # ディレクトリ内のファイルを再帰的に処理
    while IFS= read -r -d '' file; do
        rel="${file#$DOTFILES_DIR/$base/}"
        target="$target_dir/$rel"

        # .gitignore で無視されているファイルはスキップ
        if git -C "$DOTFILES_DIR" check-ignore -q "$file" 2>/dev/null; then
            continue
        fi

        mkdir -p "$(dirname "$target")"
        ln -sfn "$file" "$target"
    done < <(find "$dir" -type f -print0)
done

# ルートに配置するファイルを自動検出
for file in "$DOTFILES_DIR"/*; do
    [ -f "$file" ] || continue

    base=$(basename "$file")

    # 除外対象
    case "$base" in
        install.sh|AGENTS.md|.gitignore) continue ;;
    esac

    # .gitignore で無視されているファイルはスキップ
    if git -C "$DOTFILES_DIR" check-ignore -q "$file" 2>/dev/null; then
        continue
    fi

    ln -sfn "$file" "$HOME/$base"
done

echo "Dotfiles installation complete."
```

- [ ] **Step 3: install.sh の構文チェック**

Run: `bash -n install.sh`
Expected: 何も出力されず終了（構文エラーなし）

- [ ] **Step 4: 実際に実行して動作検証**

Run: `bash install.sh`
Expected:
- `~/.config/nvim/init.lua` がシンボリックリンクになっている
- `~/.config/nvim/` は実体のディレクトリ
- `~/.config/nvim/lazy-lock.json` は存在しない（.gitignore 対象なのでリンクされない）
- `~/.bashrc` がシンボリックリンクになっている
- `~/.config/` 下に `install.sh` や `AGENTS.md` は存在しない

確認コマンド:
```bash
ls -la ~/.config/nvim
ls -la ~/.bashrc
```

- [ ] **Step 5: 既存のディレクトリ単位リンクをクリーンアップ**

旧方式でディレクトリ単位のシンボリックリンクが残っていた場合、今回の実行で `mkdir -p` が失敗する可能性がある。

確認コマンド:
```bash
# 例: nvim がディレクトリリンクの場合、実体に置き換わっているか確認
stat ~/.config/nvim
```

もし旧リンクが残っていれば:
```bash
rm ~/.config/nvim && bash install.sh
```

- [ ] **Step 6: Commit**

```bash
git add install.sh
git commit -m "feat: auto-detect and symlink individual config files"
```
