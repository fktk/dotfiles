#!/usr/bin/env bash
set -euo pipefail

FIFO_PATH="${MUXPILOT_FIFO:-"$HOME/.config/muxpilot/notify"}"

if [[ ! -p "$FIFO_PATH" ]]; then
    echo "muxpilot FIFO not found: $FIFO_PATH" >&2
    exit 1
fi

# 引数があればそれを使い、なければ "WAITING"
KEYWORD="${1:-"WAITING"}"

echo "${TMUX_PANE} ${KEYWORD}" > "$FIFO_PATH"
