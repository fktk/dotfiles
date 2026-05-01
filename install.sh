#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Worktree 内から実行された場合でもメインリポジトリを指すようにする
if [ -d "$SCRIPT_DIR/.git" ] || [ -f "$SCRIPT_DIR/.git" ]; then
    git_common_dir="$(cd "$SCRIPT_DIR" && git rev-parse --git-common-dir)"
    DOTFILES_DIR="$(cd "$SCRIPT_DIR" && cd "$git_common_dir" && cd .. && pwd)"
else
    DOTFILES_DIR="$SCRIPT_DIR"
fi

CONFIG_DIR="$HOME/.config"

# .gitignore からディレクトリパターン（末尾が /）を読み込む
ignored_dirs=()
if [ -f "$DOTFILES_DIR/.gitignore" ]; then
    while IFS= read -r line; do
        [[ "$line" == */ ]] && ignored_dirs+=("${line%/}")
    done < <(grep -v '^#' "$DOTFILES_DIR/.gitignore" | grep -v '^$' || true)
fi

# 指定パスが .gitignore 対象かどうかを判定（サブモジュール内のファイルにも対応）
is_ignored() {
    local path="$1"
    if git -C "$DOTFILES_DIR" check-ignore -q "$path" 2>/dev/null; then
        return 0
    fi
    # エラーの場合（サブモジュール内など）は親ディレクトリで判定
    local dir_path
    dir_path=$(dirname "$path")
    while [ "$dir_path" != "$DOTFILES_DIR" ] && [ "$dir_path" != "/" ]; do
        if git -C "$DOTFILES_DIR" check-ignore -q "$dir_path" 2>/dev/null; then
            return 0
        fi
        dir_path=$(dirname "$dir_path")
    done
    return 1
}

# 相対パスが .gitignore のディレクトリパターン下にあるかチェック
is_under_ignored_dir() {
    local rel="$1"
    for ig in "${ignored_dirs[@]}"; do
        case "$rel" in
            "$ig"/*|"$ig") return 0 ;;
        esac
    done
    return 1
}

# .config 下に配置するディレクトリ群を自動検出
for dir in "$DOTFILES_DIR"/*/; do
    [ -d "$dir" ] || continue

    base=$(basename "$dir")

    # 除外対象
    case "$base" in
        .git|.worktrees|docs) continue ;;
    esac

    target_dir="$CONFIG_DIR/$base"

    # 旧方式のディレクトリ単位シンボリックリンクが残っていれば削除
    if [ -L "$target_dir" ]; then
        rm "$target_dir"
    fi

    echo "Creating directory: $target_dir"
    mkdir -p "$target_dir"

    # ディレクトリ内のファイルを再帰的に処理
    while IFS= read -r -d '' file; do
        rel="${file#$DOTFILES_DIR/$base/}"
        target="$target_dir/$rel"

        # .gitignore で無視されているファイルはスキップ
        if is_ignored "$file"; then
            continue
        fi

        # .gitignore のディレクトリパターン下にあるファイルもスキップ
        repo_rel="${file#$DOTFILES_DIR/}"
        if is_under_ignored_dir "$repo_rel"; then
            continue
        fi

        echo "Linking: $file -> $target"
        mkdir -p "$(dirname "$target")"
        ln -sfn "$file" "$target"
    done < <(find "$dir" -xtype f -print0)
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
    if is_ignored "$file"; then
        continue
    fi

    echo "Linking: $file -> $HOME/$base"
    ln -sfn "$file" "$HOME/$base"
done

echo "Dotfiles installation complete."
