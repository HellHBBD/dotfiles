#!/bin/bash

DIRS=(
    "$HOME"
    "$HOME/rust-project/"
    "$HOME/dotfiles/"
)

EXCLUDE_DIRS=(
    ".git"
    "node_modules"
    "target"
    ".cache"
    "dist"
    "build"
    ".vscode"
    ".idea"
    "__pycache__"
    ".bun"
    ".cargo"
    ".cherrystudio"
    ".claude"
    ".codex"
    ".devcontainer"
    ".github"
    ".gnupg"
    ".modelscope"
    ".ngrok"
    ".npm"
    ".nv"
    ".pki"
    ".ruff_cache"
    ".rustup"
    ".steam"
    "go"
    "funasr/output"
    "ncku-moodle-keeper/web-ext-artifacts"
    "Documents/Codex"
)

EXCLUDE_ARGS=()
for exclude in "${EXCLUDE_DIRS[@]}"; do
    EXCLUDE_ARGS+=("--exclude" "$exclude")
done

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(
        for dir in "${DIRS[@]}"; do
            if [[ -d "$dir" ]]; then
                fd . "$dir" \
                    --hidden \
                    --type=dir \
                    --max-depth=2 \
                    --full-path \
                    "${EXCLUDE_ARGS[@]}"
            fi
        done |
            sed "s|^$HOME/||" |
            fzf --border
    )
    [[ $selected ]] && selected="$HOME/$selected"
fi

[[ ! $selected ]] && exit 0

selected_name=$(basename "$selected" | tr . _)
tmux_running=$(pgrep tmux)

if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    tmux new-session -s "$selected_name" -c "$selected"
    exit 0
fi

if ! tmux has-session -t="$selected_name" 2>/dev/null; then
    tmux new-session -ds "$selected_name" -c "$selected"
fi

if [[ -z $TMUX ]]; then
    tmux attach -t "$selected_name"
else
    tmux switch-client -t "$selected_name"
fi
