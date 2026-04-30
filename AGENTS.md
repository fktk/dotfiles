# AGENTS.md — dotfiles

## What this repo is
Personal dotfiles. Every top-level directory is a tool config that gets symlinked into `~/.config` (or `~`) by `install.sh`.

## Rules when editing
- **`install.sh` auto-detects** top-level directories and files. No manual editing needed when adding/removing config directories.
- **Do not commit generated files**: `nvim/lazy-lock.json`, `tmux/plugins/`, `.worktrees/` are already in `.gitignore`.

## tmux
- **Prefix is `M-a`** (Alt+a); `C-b` is unbound.
- Most navigation binds use `-n` (no prefix) with Alt: `M-h/j/k/l` for panes, `M-n/p` for windows, `M-x` kill-pane, `M-H/J/K/L` resize.
- Plugins are managed by **TPM**. Declare with `set -g @plugin "..."` and install with `prefix + I`.
- `tmuxp/` contains session-layout YAMLs (e.g., `tmuxp load memo`).

## OpenCode
- Config lives in `opencode/`. The repo loads the `superpowers` skill plugin.
- `opencode.json` sets **all permissions to `allow`**.

## Tool configs included
- `nvim/` — Neovim (Lua, lazy.nvim)
- `tmux/` — tmux + TPM + powerkit
- `yazi/` — file manager (Lua/TOML)
- `ghostty/` — terminal emulator
- `lazygit/` — TUI Git client
- `tmuxp/` — tmux session presets (YAML)
