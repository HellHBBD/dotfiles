#!/bin/bash

set -euo pipefail

DIRS=(
    "$HOME"
    "$HOME/rust-project"
    "$HOME/dotfiles"
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

if [[ "${HERDR_ENV:-}" != 1 ]]; then
    printf '%s\n' 'herdr-sessionizer must run inside a Herdr pane' >&2
    exit 1
fi

if [[ $# -eq 1 ]]; then
    selected="$1"
else
    exclude_args=()
    for exclude in "${EXCLUDE_DIRS[@]}"; do
        exclude_args+=("--exclude" "$exclude")
    done

    selected=$(for dir in "${DIRS[@]}"; do
        if [[ -d "$dir" ]]; then
            fd . "$dir" \
                --hidden \
                --type=dir \
                --max-depth=2 \
                --full-path \
                "${exclude_args[@]}"
        fi
    done | sed "s|^$HOME/||" | fzf --border) || exit 0
    selected="$HOME/$selected"
fi

selected=$(realpath -e -- "$selected")
[[ -d "$selected" ]] || exit 1

workspace_list=$(herdr workspace list)
workspace_id=$(jq -r --arg path "$selected" '
    first(
        .result.workspaces[]
        | select(.worktree.checkout_path? == $path)
        | .workspace_id
    ) // empty
' <<<"$workspace_list")

if [[ -z "$workspace_id" ]]; then
    while IFS= read -r candidate_id; do
        pane_list=$(herdr pane list --workspace "$candidate_id")
        if jq -e --arg path "$selected" '
            any(.result.panes[]; .cwd == $path or .foreground_cwd == $path)
        ' <<<"$pane_list" >/dev/null; then
            workspace_id="$candidate_id"
            break
        fi
    done < <(jq -r '.result.workspaces[].workspace_id' <<<"$workspace_list")
fi

if [[ -n "$workspace_id" ]]; then
    herdr workspace focus "$workspace_id"
else
    herdr workspace create --cwd "$selected" --label "$(basename "$selected")" --focus
fi
