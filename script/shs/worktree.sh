#!/usr/bin/env bash
set -euo pipefail

WORKTREE_BASE="${XDG_DATA_HOME:-$HOME/.local/share}/worktrees"

INITIALIZATION_PROMPT='Initialize this worktree session. Inspect the repository only. Do not modify files or create commits. Wait for further instructions.'

command -v git >/dev/null || {
    echo '找不到 git' >&2
    exit 1
}

command -v gum >/dev/null || {
    echo '找不到 gum' >&2
    exit 1
}

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
    echo '目前不在 Git repository 中' >&2
    exit 1
}

repo_root="$(git rev-parse --show-toplevel)"
project="$(basename "$repo_root")"
current_branch="$(git branch --show-current)"
project_dir="$WORKTREE_BASE/$project"
status="$(git status --short)"

if [[ -z "$current_branch" ]]; then
    echo '目前是 detached HEAD，請先切換到分支' >&2
    exit 1
fi

printf 'Project: %s\n' "$project"
printf 'Current branch: %s\n' "$current_branch"
printf 'Worktree root: %s\n\n' "$project_dir"

if [[ -n "$status" ]]; then
    printf '警告：目前有未提交變更\n\n%s\n\n' "$status" >&2
fi

add_worktree() {
    local branch
    local worktree_path
    local session_title
    local session_log

    branch="$(
        gum input \
            --header "從 $current_branch 建立新 worktree" \
            --placeholder 'feature/name'
    )" || return

    [[ -n "$branch" ]] || return

    if ! git check-ref-format --branch "$branch" >/dev/null 2>&1; then
        echo "不合法的 branch 名稱：$branch" >&2
        return 1
    fi

    worktree_path="$project_dir/$branch"
    session_title="$project:$branch"

    printf '\nBranch: %s\n' "$branch"
    printf 'Worktree: %s\n\n' "$worktree_path"

    gum confirm '確認建立？' || return

    mkdir -p "$(dirname "$worktree_path")"

    git worktree add \
        -b "$branch" \
        "$worktree_path" \
        HEAD

    if ! command -v opencode >/dev/null; then
        echo '找不到 opencode；branch 和 worktree 已建立，但沒有建立 session' >&2
        return 1
    fi

    session_log="$(mktemp)"

    session_log="$(mktemp)"

    (
        if opencode run \
            --pure \
            --dir "$worktree_path" \
            --title "$session_title" \
            --agent build \
            "$INITIALIZATION_PROMPT" \
            >"$session_log" 2>&1; then
            rm -f "$session_log"
        else
            printf 'OpenCode session 建立失敗，Log: %s\n' \
                "$session_log" >&2
        fi
    ) </dev/null &

    printf 'OpenCode session 正在背景初始化\n'

    printf '\n建立完成\n'
    printf 'Branch: %s\n' "$branch"
    printf 'Worktree: %s\n' "$worktree_path"
    printf 'Session: %s\n' "$session_title"
}

merge_branches() {
    local branches
    local selected
    local branch
    local worktree_path

    branches="$(
        git for-each-ref \
            --format='%(refname:short)' \
            refs/heads |
            grep -Fxv "$current_branch" ||
            true
    )"

    if [[ -z "$branches" ]]; then
        echo '沒有其他本地 branch'
        return
    fi

    selected="$(
        printf '%s\n' "$branches" |
            gum filter \
                --no-limit \
                --height 15 \
                --header "選擇要合併到 $current_branch 的 branch"
    )" || return

    [[ -n "$selected" ]] || return

    printf '\n將依序合併到 %s：\n' "$current_branch"
    printf '%s\n' "$selected" | sed 's/^/  - /'
    printf '\n'

    gum confirm '開始合併？' || return

    mapfile -t selected_branches <<<"$selected"

    for branch in "${selected_branches[@]}"; do
        [[ -n "$branch" ]] || continue

        printf '\n合併 %s\n' "$branch"

        if ! git merge --no-ff --no-edit "$branch"; then
            printf '\n合併失敗，已停止：%s\n' "$branch" >&2
            printf '請使用 git status 查看狀態。\n' >&2
            printf '取消合併可執行：git merge --abort\n' >&2
            exit 1
        fi

        echo "合併完成：$branch"

        if gum confirm "刪除 $branch 及其 worktree？"; then
            worktree_path="$(
                git worktree list --porcelain |
                    awk -v target="refs/heads/$branch" '
                        /^worktree / {
                            path = substr($0, 10)
                        }

                        /^branch / &&
                        substr($0, 8) == target {
                            print path
                        }
                    '
            )"

            if [[ -n "$worktree_path" ]]; then
                git worktree remove "$worktree_path"
            fi

            git branch -d "$branch"
        fi
    done

    git worktree prune

    printf '\n全部處理完成\n'
}

while true; do
    action="$(
        gum choose \
            'add    建立 branch、worktree 和 OpenCode session' \
            'merge  選擇並合併 branch' \
            'quit   離開'
    )" || exit 0

    clear
    case "$action" in
    add*)
        add_worktree
        ;;

    merge*)
        merge_branches
        ;;

    *)
        exit 0
        ;;
    esac
    printf '\n'
    # gum confirm '返回主選單？' \
    #     --affirmative '返回' \
    #     --negative '離開' || exit 0
done
