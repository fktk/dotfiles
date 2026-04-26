#!/bin/bash
set -e

SESSION_NAME="$1"

if [ -z "$SESSION_NAME" ]; then
    echo "Usage: $0 <session_name>"
    exit 1
fi

while true; do
    sleep "${TABBY_PERIODIC_INTERVAL:-1}"s
    
    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        current=$(tmux display-message -t "$SESSION_NAME" -p "#{window_index}")
        tmux select-window -t "$SESSION_NAME:$current" 2>/dev/null || true
    else
        exit 0
    fi
done
