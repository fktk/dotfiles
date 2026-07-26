# AGENTS.md — dotfiles

## What this repo is
Personal dotfiles. Every top-level directory is a tool config that gets symlinked into `~/.config` (or `~`) by `install.sh`.

## Rules when editing
- **`install.sh` auto-detects** top-level directories and files. No manual editing needed when adding/removing config directories.
- **Do not commit generated files**: `nvim/lazy-lock.json`, `tmux/plugins/`, `.worktrees/` are already in `.gitignore`.
