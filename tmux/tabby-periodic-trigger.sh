#!/bin/bash
# ~/.tmux/plugins/tabby/scripts/periodic-trigger.sh

set -e

while true; do
    sleep "${TABBY_PERIODIC_INTERVAL:-1}"s
    
    tmux list-sessions -F "#{session_name}" 2>/dev/null | while read -r session; do
        # ウィンドウの "選択を更新" することで render をトリガー
        current=$(tmux display-message -t "$session" -p "#{window_index}")
        tmux select-window -t "$session:$current" 2>/dev/null || true
    done
done
