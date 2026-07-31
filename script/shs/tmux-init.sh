#!/usr/bin/env bash

# MINECRAFT_DIR="$HOME/.local/share/PrismLauncher/instances/server/minecraft"
# MINECRAFT_WORLD_DIR="$HOME/.local/share/PrismLauncher/instances/server/minecraft/world"
# GEMINI_DIR="$HOME/gemini-balance"
# CLAUDE_DIR="$HOME/.claude-code-router"

ensure_tmux_session() {
    local session_name="$1"
    local working_directory="$2"
    local first_window
    local window_name

    if tmux has-session -t "=$session_name" 2>/dev/null; then
        return
    fi

    shift 2
    if (($# == 0)); then
        tmux new-session -d -s "$session_name" -c "$working_directory"
        return
    fi

    first_window="$1"
    tmux new-session -d -s "$session_name" -n "$first_window" -c "$working_directory"
    shift

    for window_name in "$@"; do
        tmux new-window -t "$session_name" -n "$window_name" -c "$working_directory"
    done

    tmux select-window -t "${session_name}:${first_window}"
}

ensure_tmux_session "backend" "$HOME" "Backend Process"
ensure_tmux_session "home" "$HOME"
# ensure_tmux_session "dotfiles" "$HOME/dotfiles" "Code" "Build"
# ensure_tmux_session "bom" "$HOME/bom" "Code" "Build"
