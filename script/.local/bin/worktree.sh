#!/usr/bin/env bash
set -euo pipefail

readonly EXIT_USAGE=2
readonly EXIT_REPOSITORY=3
readonly EXIT_WORKTREE=4
readonly EXIT_SESSION=5
readonly EXIT_MERGE=6
readonly EXIT_CLEANUP=7

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly WORKTREE_BIN_DIR="$SCRIPT_DIR/../libexec/dotfiles/worktree-bin"
WORKTREE_BASE="${XDG_DATA_HOME:-$HOME/.local/share}/worktrees"
DEFAULT_INITIALIZATION_PROMPT='初始化 worktree 工作階段。請勿讀取或修改檔案、執行工具或開始工作，只回覆「已初始化」。'

repo_arg='.'
repo_root=''
project=''
project_dir=''
current_branch=''
json=false
yes=false
dry_run=false
command_name=''
merge_target_status=''
merge_target_clean=true
merge_target_changes_json='[]'
merge_warnings_json='[]'
merge_cleanup_warnings_json='[]'
sandbox_worktree=''
sandbox_git_dir=''
sandbox_git_common_dir=''
sandbox_runtime_dir=''
sandbox_data_home=''
sandbox_state_home=''
sandbox_cache_home=''
sandbox_tmpdir=''
sandbox_branch=''

usage() {
    cat <<'EOF'
Usage:
  worktree.sh [--repo <path>] [--json] [--dry-run] [--yes] <command> [options]
  worktree.sh

Commands:
  add <branch> [--base <ref>] [--agent <name>] [--prompt <text> |
      --prompt-file <path>] [--title <title>] [--session | --no-session]
      [--wait | --detach]
  merge <branch...> [--target <branch>] [--delete | --keep]
  list
  status

Global options:
  --repo <path>  Repository to operate on (default: current directory)
  --yes          Confirm destructive command-mode operations
  --json         Emit one JSON result document on stdout
  --dry-run      Print planned mutations without executing them
  --help         Show this help

Without a command, starts the interactive Gum interface.
EOF
}

require_command() {
    command -v "$1" >/dev/null 2>&1 || {
        printf '找不到 %s\n' "$1" >&2
        exit "$EXIT_USAGE"
    }
}

require_jq_for_json() {
    if "$json"; then
        require_command jq
    fi
}

json_array() {
    if (($# == 0)); then
        printf '[]'
    else
        printf '%s\n' "$@" | jq -R . | jq -s .
    fi
}

emit_error() {
    local status="$1"
    local message="$2"

    if "$json"; then
        jq -cn --arg status "$status" --arg command "$command_name" --arg message "$message" \
            '{status: $status, command: $command, message: $message}'
    else
        printf '%s\n' "$message" >&2
    fi
}

fail() {
    local code="$1"
    local status="$2"
    local message="$3"

    emit_error "$status" "$message"
    exit "$code"
}

progress() {
    if ! "$json"; then
        printf '%s\n' "$*" >&2
    fi
}

parse_global_option() {
    local option="$1"
    local value="${2-}"

    PARSED_COUNT=0
    case "$option" in
    --repo)
        [[ -n "$value" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' '--repo 需要路徑參數'
        repo_arg="$value"
        PARSED_COUNT=2
        ;;
    --yes)
        yes=true
        PARSED_COUNT=1
        ;;
    --json)
        json=true
        PARSED_COUNT=1
        ;;
    --dry-run)
        dry_run=true
        PARSED_COUNT=1
        ;;
    --help | -h)
        usage
        exit 0
        ;;
    *)
        return 1
        ;;
    esac
}

initialize_repository() {
    require_command git

    repo_root="$(git -C "$repo_arg" rev-parse --show-toplevel 2>/dev/null)" ||
        fail "$EXIT_REPOSITORY" 'NOT_A_REPOSITORY' '指定路徑不在 Git repository 中'

    project="$(basename "$repo_root")"
    project_dir="$WORKTREE_BASE/$project"
    current_branch="$(git -C "$repo_root" branch --show-current)"
}

require_current_branch() {
    [[ -n "$current_branch" ]] ||
        fail "$EXIT_REPOSITORY" 'DETACHED_HEAD' '目前是 detached HEAD，請先切換到分支'
}

worktree_path_for_branch() {
    local branch="$1"

    git -C "$repo_root" worktree list --porcelain |
        awk -v target="refs/heads/$branch" '
            /^worktree / {
                path = substr($0, 10)
            }

            /^branch / && substr($0, 8) == target {
                print path
                exit
            }
        '
}

is_registered_worktree_path() {
    local path="$1"

    git -C "$repo_root" worktree list --porcelain |
        awk -v target="$path" '
            /^worktree / && substr($0, 10) == target {
                found = 1
            }

            END {
                exit !found
            }
        '
}

is_clean_worktree() {
    local path="$1"
    local worktree_status

    worktree_status="$(git -C "$path" status --porcelain)" || return 1
    [[ -z "$worktree_status" ]]
}

emit_add_result() {
    local status="$1"
    local branch="$2"
    local worktree_path="$3"
    local session_title="$4"
    local session_log="${5-}"
    local herdr_workspace="${6-}"
    local session_id="${7-}"

    if "$json"; then
        jq -cn \
            --arg status "$status" \
            --arg command 'add' \
            --arg branch "$branch" \
            --arg worktree "$worktree_path" \
            --arg session "$session_title" \
            --arg log "$session_log" \
            --arg herdr_workspace "$herdr_workspace" \
            --arg session_id "$session_id" \
            '{status: $status, command: $command, branch: $branch, worktree: $worktree} +
              (if $session == "" then {} else {session: $session} end) +
              (if $log == "" then {} else {log: $log} end) +
              (if $herdr_workspace == "" then {} else {herdr_workspace: $herdr_workspace} end) +
              (if $session_id == "" then {} else {session_id: $session_id} end)'
    else
        printf 'Branch: %s\nWorktree: %s\n' "$branch" "$worktree_path"
        [[ -n "$session_title" ]] && printf 'Session: %s\n' "$session_title"
        [[ -n "$session_id" ]] && printf 'Session ID: %s\n' "$session_id"
        [[ -n "$herdr_workspace" ]] && printf 'Herdr workspace: %s\n' "$herdr_workspace"
        [[ -n "$session_log" ]] && printf 'Log: %s\n' "$session_log"
    fi
}

reset_add_options() {
    add_base='HEAD'
    add_agent="${OPENCODE_AGENT:-build}"
    add_prompt="${OPENCODE_INITIALIZATION_PROMPT:-$DEFAULT_INITIALIZATION_PROMPT}"
    add_prompt_file=''
    add_prompt_provided=false
    add_title=''
    add_session=true
    add_wait=true
}

validate_add() {
    local branch="$1"
    local worktree_path="$2"

    [[ -n "$branch" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' 'add 需要 branch 名稱'
    git -C "$repo_root" check-ref-format --branch "$branch" >/dev/null 2>&1 ||
        fail "$EXIT_USAGE" 'INVALID_BRANCH' "不合法的 branch 名稱：$branch"
    git -C "$repo_root" rev-parse --verify --quiet "${add_base}^{commit}" >/dev/null ||
        fail "$EXIT_USAGE" 'INVALID_BASE' "找不到 base ref：$add_base"
    ! git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch" ||
        fail "$EXIT_WORKTREE" 'BRANCH_EXISTS' "branch 已存在：$branch"
    [[ ! -e "$worktree_path" && ! -L "$worktree_path" ]] ||
        fail "$EXIT_WORKTREE" 'WORKTREE_PATH_EXISTS' "worktree 路徑已存在：$worktree_path"
    ! is_registered_worktree_path "$worktree_path" ||
        fail "$EXIT_WORKTREE" 'WORKTREE_EXISTS' "worktree 已註冊：$worktree_path"

    if [[ -n "$add_prompt_file" ]]; then
        [[ -r "$add_prompt_file" && -f "$add_prompt_file" ]] ||
            fail "$EXIT_USAGE" 'INVALID_PROMPT_FILE' "prompt 檔案不可讀：$add_prompt_file"
        add_prompt="$(<"$add_prompt_file")"
    fi

    if "$add_session" && ! "$dry_run"; then
        command -v opencode >/dev/null 2>&1 ||
            fail "$EXIT_USAGE" 'OPENCODE_NOT_FOUND' '找不到 opencode'
        command -v herdr >/dev/null 2>&1 ||
            fail "$EXIT_USAGE" 'HERDR_NOT_FOUND' '找不到 herdr'
        command -v bwrap >/dev/null 2>&1 ||
            fail "$EXIT_USAGE" 'BWRAP_NOT_FOUND' '找不到 bwrap'
        [[ -x "$WORKTREE_BIN_DIR/opencode" && -x "$WORKTREE_BIN_DIR/git" ]] ||
            fail "$EXIT_USAGE" 'SANDBOX_WRAPPER_NOT_FOUND' "找不到 sandbox wrapper：$WORKTREE_BIN_DIR"
        require_command jq
    fi
}

prepare_sandbox() {
    local worktree_path="$1"
    local branch="$2"

    sandbox_worktree="$(realpath -e -- "$worktree_path")" || return 1
    sandbox_git_dir="$(git -C "$sandbox_worktree" rev-parse --absolute-git-dir)" || return 1
    sandbox_git_common_dir="$(git -C "$sandbox_worktree" rev-parse --git-common-dir)" || return 1
    sandbox_git_dir="$(realpath -e -- "$sandbox_git_dir")" || return 1
    sandbox_git_common_dir="$(realpath -e -- "$sandbox_git_common_dir")" || return 1
    sandbox_runtime_dir="$project_dir/.opencode/$branch"
    sandbox_data_home="$sandbox_runtime_dir/data"
    sandbox_state_home="$sandbox_runtime_dir/state"
    sandbox_cache_home="$sandbox_runtime_dir/cache"
    sandbox_tmpdir="$sandbox_runtime_dir/tmp"
    sandbox_branch="$branch"

    mkdir -p "$sandbox_data_home" "$sandbox_state_home" "$sandbox_cache_home" "$sandbox_tmpdir"
}

run_sandboxed_opencode() {
    WORKTREE_SANDBOX_WORKTREE="$sandbox_worktree" \
        WORKTREE_SANDBOX_GIT_DIR="$sandbox_git_dir" \
        WORKTREE_SANDBOX_GIT_COMMON_DIR="$sandbox_git_common_dir" \
        WORKTREE_SANDBOX_DATA_HOME="$sandbox_data_home" \
        WORKTREE_SANDBOX_STATE_HOME="$sandbox_state_home" \
        WORKTREE_SANDBOX_CACHE_HOME="$sandbox_cache_home" \
        WORKTREE_SANDBOX_TMPDIR="$sandbox_tmpdir" \
        WORKTREE_SANDBOX_BRANCH="$sandbox_branch" \
        "$WORKTREE_BIN_DIR/opencode" "$@"
}

open_herdr_workspace() {
    local worktree_path="$1"
    local session_title="$2"

    herdr_log="$(mktemp "${TMPDIR:-/tmp}/worktree-herdr-${project}-${branch//\//-}.XXXXXX.log")"
    if ! herdr worktree open \
        --cwd "$repo_root" \
        --path "$worktree_path" \
        --label "$session_title" \
        --no-focus \
        --json >"$herdr_log" 2>&1; then
        return 1
    fi

    herdr_workspace="$(jq -er '.result.workspace.workspace_id' "$herdr_log")" || return 1
    herdr_root_pane="$(jq -er '.result.root_pane.pane_id' "$herdr_log")" || return 1
}

initialize_opencode_session() {
    local worktree_path="$1"
    local session_title="$2"

    if ! run_sandboxed_opencode run --pure --format json --dir "$worktree_path" --title "$session_title" \
        --agent "$add_agent" "$add_prompt" >"$session_log" 2>&1; then
        return 1
    fi

    session_id="$(jq -rs 'map(select(.sessionID? != null).sessionID) | last // empty' "$session_log")"
    [[ -n "$session_id" ]]
}

configure_herdr_sandbox() {
    local value
    local assignment
    local command=''
    local sentinel="WORKTREE_SANDBOX_READY:${herdr_root_pane}:${session_id}"
    local -a names=(
        WORKTREE_SANDBOX_WORKTREE
        WORKTREE_SANDBOX_GIT_DIR
        WORKTREE_SANDBOX_GIT_COMMON_DIR
        WORKTREE_SANDBOX_DATA_HOME
        WORKTREE_SANDBOX_STATE_HOME
        WORKTREE_SANDBOX_CACHE_HOME
        WORKTREE_SANDBOX_TMPDIR
        WORKTREE_SANDBOX_BRANCH
        PATH
    )
    local -a values=(
        "$sandbox_worktree"
        "$sandbox_git_dir"
        "$sandbox_git_common_dir"
        "$sandbox_data_home"
        "$sandbox_state_home"
        "$sandbox_cache_home"
        "$sandbox_tmpdir"
        "$sandbox_branch"
        "$WORKTREE_BIN_DIR:$PATH"
    )
    local index

    for index in "${!names[@]}"; do
        value="${values[index]}"
        printf -v assignment '%s=%q' "${names[index]}" "$value"
        command+="export $assignment; "
    done
    printf -v value '%q' "$sentinel"
    command+="printf '%s\\n' $value"

    herdr pane run "$herdr_root_pane" "$command" >&2 || return 1
    herdr pane wait-output "$herdr_root_pane" --match "$sentinel" --timeout 30000 >&2
}

start_herdr_opencode() {
    local agent_name="wt-${BASHPID}"

    configure_herdr_sandbox || return 1
    herdr agent start "$agent_name" --kind opencode --pane "$herdr_root_pane" -- \
        --session "$session_id" --agent "$add_agent" >>"$session_log" 2>&1
}

initialize_herdr_session() {
    initialize_opencode_session "$worktree_path" "$session_title" && start_herdr_opencode
}

add_branch() {
    local branch="$1"
    local worktree_path="$project_dir/$branch"
    local session_title
    local session_log
    local herdr_log=''
    local herdr_workspace=''
    local herdr_root_pane=''
    local session_id=''

    session_title="${add_title:-$branch}"
    validate_add "$branch" "$worktree_path"

    if "$dry_run"; then
        if "$json"; then
            jq -cn \
                --arg branch "$branch" \
                --arg worktree "$worktree_path" \
                --arg base "$add_base" \
                --arg session "$session_title" \
                --arg agent "$add_agent" \
                --argjson create_session "$add_session" \
                '{status: "DRY_RUN", command: "add", branch: $branch, worktree: $worktree,
                  operations: (["git worktree add -b " + $branch + " " + $worktree + " " + $base] +
                   (if $create_session then ["create isolated OpenCode sandbox runtime",
                     "herdr worktree open --path " + $worktree,
                     "sandboxed opencode run --agent " + $agent,
                     "configure Herdr sandbox environment",
                     "herdr agent start --kind opencode"] else [] end)),
                  session: $session}'
        else
            printf 'DRY RUN: git -C %q worktree add -b %q %q %q\n' \
                "$repo_root" "$branch" "$worktree_path" "$add_base"
            if "$add_session"; then
                printf 'DRY RUN: herdr worktree open --cwd %q --path %q --label %q --no-focus\n' \
                    "$repo_root" "$worktree_path" "$session_title"
                printf 'DRY RUN: create isolated OpenCode runtime under %q/.opencode/%q\n' \
                    "$project_dir" "$branch"
                printf 'DRY RUN: sandboxed opencode run --pure --format json --agent %q --dir %q\n' \
                    "$add_agent" "$worktree_path"
                printf 'DRY RUN: export sandbox environment in the Herdr root pane\n'
                printf 'DRY RUN: herdr agent start wt-<pid> --kind opencode --pane <root-pane> -- --session <session-id> --agent %q\n' \
                    "$add_agent"
            fi
        fi
        return
    fi

    mkdir -p "$(dirname "$worktree_path")"
    progress "建立 worktree：$worktree_path"
    if ! git -C "$repo_root" worktree add -b "$branch" "$worktree_path" "$add_base" >&2; then
        fail "$EXIT_WORKTREE" 'WORKTREE_CREATE_FAILED' "無法建立 worktree：$worktree_path"
    fi

    if ! "$add_session"; then
        emit_add_result 'OK' "$branch" "$worktree_path" ''
        return
    fi

    if ! prepare_sandbox "$worktree_path" "$branch"; then
        emit_add_result 'WORKTREE_CREATED_SANDBOX_FAILED' "$branch" "$worktree_path" "$session_title"
        exit "$EXIT_SESSION"
    fi

    progress "建立 Herdr workspace：$session_title"
    if ! open_herdr_workspace "$worktree_path" "$session_title"; then
        emit_add_result 'WORKTREE_CREATED_HERDR_FAILED' "$branch" "$worktree_path" "$session_title" "$herdr_log"
        exit "$EXIT_SESSION"
    fi
    rm -f "$herdr_log"

    session_log="$(mktemp "${TMPDIR:-/tmp}/worktree-${project}-${branch//\//-}.XXXXXX.log")"
    if "$add_wait"; then
        progress "初始化 OpenCode session：$session_title"
        if ! initialize_opencode_session "$worktree_path" "$session_title"; then
            emit_add_result 'WORKTREE_CREATED_SESSION_FAILED' "$branch" "$worktree_path" "$session_title" "$session_log" "$herdr_workspace"
            exit "$EXIT_SESSION"
        fi
        progress "在 Herdr 啟動 OpenCode：$session_title"
        if start_herdr_opencode; then
            emit_add_result 'OK' "$branch" "$worktree_path" "$session_title" '' "$herdr_workspace" "$session_id"
            rm -f "$session_log"
        else
            emit_add_result 'WORKTREE_CREATED_SESSION_START_FAILED' "$branch" "$worktree_path" "$session_title" "$session_log" "$herdr_workspace" "$session_id"
            exit "$EXIT_SESSION"
        fi
    else
        (
            if ! initialize_herdr_session; then
                printf 'OpenCode session initialization or Herdr launch failed\n' >>"$session_log"
            fi
        ) </dev/null &
        emit_add_result 'SESSION_INITIALIZING' "$branch" "$worktree_path" "$session_title" "$session_log" "$herdr_workspace"
    fi
}

emit_merge_failure() {
    local status="$1"
    local failed_branch="$2"
    local merged_json="$3"
    local remaining_json="$4"

    if "$json"; then
        jq -cn \
            --arg status "$status" \
            --arg command 'merge' \
            --arg branch "$failed_branch" \
            --argjson merged "$merged_json" \
            --argjson remaining "$remaining_json" \
            --argjson target_clean "$merge_target_clean" \
            --argjson target_changes_before "$merge_target_changes_json" \
            --argjson warnings "$merge_warnings_json" \
            '{status: $status, command: $command, failed_branch: $branch,
              merged: $merged, remaining: $remaining, merge_aborted: false,
              target_clean: $target_clean, target_changes_before: $target_changes_before,
              warnings: $warnings}'
    else
        printf '\n合併失敗，已停止：%s\n' "$failed_branch" >&2
        printf '請使用 git status 查看狀態。\n' >&2
        printf '取消合併可執行：git merge --abort\n' >&2
    fi
}

capture_merge_target_state() {
    local -a changes=()

    merge_target_status="$(git -C "$repo_root" status --short)" ||
        fail "$EXIT_REPOSITORY" 'TARGET_STATUS_FAILED' '無法取得 target worktree 狀態'
    merge_target_clean=true
    merge_target_changes_json='[]'
    merge_warnings_json='[]'
    merge_cleanup_warnings_json='[]'

    if [[ -n "$merge_target_status" ]]; then
        merge_target_clean=false
        mapfile -t changes <<<"$merge_target_status"
        if "$json"; then
            merge_target_changes_json="$(json_array "${changes[@]}")"
            merge_warnings_json='["DIRTY_TARGET"]'
        fi
    fi
}

record_cleanup_warning() {
    local message="$1"

    if "$json"; then
        merge_cleanup_warnings_json="$(jq -cn \
            --argjson warnings "$merge_cleanup_warnings_json" \
            --arg message "$message" \
            '$warnings + [$message]')"
    else
        printf '警告：%s\n' "$message" >&2
    fi
}

close_herdr_workspaces_for_worktree() {
    local worktree_path="$1"
    local workspace_list
    local workspace_ids
    local workspace_id

    command -v herdr >/dev/null 2>&1 || return
    if ! command -v jq >/dev/null 2>&1; then
        record_cleanup_warning "找不到 jq，可能留下對應 Herdr 視窗：$worktree_path"
        return
    fi

    if ! workspace_list="$(herdr workspace list 2>&1)"; then
        record_cleanup_warning "無法查詢 Herdr workspace，可能留下對應視窗：$worktree_path"
        return
    fi

    if ! workspace_ids="$(jq -r --arg path "$worktree_path" \
        '.result.workspaces[]? | select(.worktree.checkout_path? == $path) | .workspace_id' \
        <<<"$workspace_list")"; then
        record_cleanup_warning "無法解析 Herdr workspace，可能留下對應視窗：$worktree_path"
        return
    fi

    while IFS= read -r workspace_id; do
        [[ -n "$workspace_id" ]] || continue
        progress "關閉 Herdr workspace：$workspace_id"
        if ! herdr workspace close "$workspace_id" >&2; then
            record_cleanup_warning "無法關閉 Herdr workspace $workspace_id：$worktree_path"
        fi
    done <<<"$workspace_ids"
}

dry_run_herdr_cleanup() {
    local worktree_path="$1"
    local workspace_list
    local workspace_ids
    local workspace_id

    command -v herdr >/dev/null 2>&1 || return
    command -v jq >/dev/null 2>&1 || {
        printf 'DRY RUN: unable to parse Herdr workspace without jq for %q\n' "$worktree_path"
        return
    }

    if ! workspace_list="$(herdr workspace list 2>/dev/null)"; then
        printf 'DRY RUN: unable to query Herdr workspace for %q\n' "$worktree_path"
        return
    fi

    if ! workspace_ids="$(jq -r --arg path "$worktree_path" \
        '.result.workspaces[]? | select(.worktree.checkout_path? == $path) | .workspace_id' \
        <<<"$workspace_list")"; then
        printf 'DRY RUN: unable to parse Herdr workspace for %q\n' "$worktree_path"
        return
    fi

    while IFS= read -r workspace_id; do
        [[ -n "$workspace_id" ]] || continue
        printf 'DRY RUN: herdr workspace close %q\n' "$workspace_id"
    done <<<"$workspace_ids"
}

warn_dirty_merge_target() {
    "$merge_target_clean" && return
    "$json" && return

    printf '\n警告：target worktree 有未提交變更，將直接嘗試合併。\n' >&2
    printf '%s\n' "$merge_target_status" >&2
    printf '%s\n' 'staged changes 通常會讓 Git 拒絕 merge；重疊的 local changes 也會讓 Git 停止。' >&2
    printf '%s\n' '不重疊的 unstaged changes 可能會被保留；若發生 conflict，merge --abort 未必能完整還原它們。' >&2
}

validate_merge() {
    local branch
    local worktree_path
    local -A seen=()
    local target="$1"
    shift

    require_current_branch
    [[ "$target" == "$current_branch" ]] ||
        fail "$EXIT_REPOSITORY" 'INVALID_TARGET' '--target 必須是目前 checkout 的 branch'
    (($# > 0)) || fail "$EXIT_USAGE" 'USAGE_ERROR' 'merge 至少需要一個 branch'

    for branch in "$@"; do
        [[ "$branch" != "$target" ]] ||
            fail "$EXIT_USAGE" 'INVALID_BRANCH' '不能將 target branch 合併到自己'
        [[ -z "${seen[$branch]+x}" ]] ||
            fail "$EXIT_USAGE" 'DUPLICATE_BRANCH' "重複的 branch：$branch"
        seen["$branch"]=1
        git -C "$repo_root" show-ref --verify --quiet "refs/heads/$branch" ||
            fail "$EXIT_USAGE" 'UNKNOWN_BRANCH' "找不到 branch：$branch"
    done

    if "$merge_delete" && ! "$dry_run" && ! "$yes"; then
        fail "$EXIT_USAGE" 'CONFIRMATION_REQUIRED' '--delete 需要搭配 --yes'
    fi

    if "$merge_delete"; then
        for branch in "$@"; do
            worktree_path="$(worktree_path_for_branch "$branch")"
            if [[ -n "$worktree_path" ]] && ! is_clean_worktree "$worktree_path"; then
                fail "$EXIT_CLEANUP" 'DIRTY_SOURCE_WORKTREE' "來源 worktree 有未提交變更：$worktree_path"
            fi
        done
    fi
}

merge_branches() {
    local target="$1"
    shift
    local -a branches=("$@")
    local -a merged=()
    local -a remaining=()
    local branch
    local index
    local worktree_path
    local merged_json
    local remaining_json
    local merge_status='OK'

    validate_merge "$target" "${branches[@]}"
    capture_merge_target_state
    warn_dirty_merge_target

    if "$dry_run"; then
        if "$json"; then
            jq -cn \
                --arg target "$target" \
                --argjson branches "$(json_array "${branches[@]}")" \
                --argjson delete "$merge_delete" \
                --argjson target_clean "$merge_target_clean" \
                --argjson target_changes_before "$merge_target_changes_json" \
                --argjson warnings "$merge_warnings_json" \
                '{status: "DRY_RUN", command: "merge", target: $target, branches: $branches,
                  delete: $delete, target_clean: $target_clean,
                  target_changes_before: $target_changes_before, warnings: $warnings}'
        else
            for branch in "${branches[@]}"; do
                printf 'DRY RUN: git -C %q merge --no-ff --no-edit %q\n' "$repo_root" "$branch"
                if "$merge_delete"; then
                    worktree_path="$(worktree_path_for_branch "$branch")"
                    [[ -n "$worktree_path" ]] && dry_run_herdr_cleanup "$worktree_path"
                    printf 'DRY RUN: remove worktree and delete branch %q\n' "$branch"
                fi
            done
        fi
        return
    fi

    for index in "${!branches[@]}"; do
        branch="${branches[index]}"
        progress "合併 $branch"
        if git -C "$repo_root" merge --no-ff --no-edit "$branch" >&2; then
            merged+=("$branch")
            continue
        fi

        remaining=("${branches[@]:index}")
        if git -C "$repo_root" rev-parse --verify --quiet MERGE_HEAD >/dev/null; then
            merge_status='MERGE_CONFLICT'
        else
            merge_status='MERGE_FAILED'
        fi
        if "$json"; then
            merged_json="$(json_array "${merged[@]}")"
            remaining_json="$(json_array "${remaining[@]}")"
            emit_merge_failure "$merge_status" "$branch" "$merged_json" "$remaining_json"
        else
            emit_merge_failure "$merge_status" "$branch" '[]' '[]'
        fi
        exit "$EXIT_MERGE"
    done

    if "$merge_delete"; then
        for branch in "${branches[@]}"; do
            cleanup_branch "$branch"
        done
        git -C "$repo_root" worktree prune >&2
    fi

    if "$json"; then
        jq -cn \
            --arg target "$target" \
            --argjson merged "$(json_array "${merged[@]}")" \
            --argjson deleted "$merge_delete" \
            --argjson target_clean "$merge_target_clean" \
            --argjson target_changes_before "$merge_target_changes_json" \
            --argjson warnings "$(jq -cn --argjson target "$merge_warnings_json" --argjson cleanup "$merge_cleanup_warnings_json" '$target + $cleanup')" \
            '{status: "OK", command: "merge", target: $target, merged: $merged, deleted: $deleted,
              target_clean: $target_clean, target_changes_before: $target_changes_before,
              warnings: $warnings}'
    else
        printf '\n全部處理完成\n'
    fi
}

cleanup_branch() {
    local branch="$1"
    local worktree_path
    local worktree_runtime_dir

    worktree_path="$(worktree_path_for_branch "$branch")"
    if [[ -n "$worktree_path" ]]; then
        close_herdr_workspaces_for_worktree "$worktree_path"
        progress "移除 worktree：$worktree_path"
        if ! git -C "$repo_root" worktree remove "$worktree_path" >&2; then
            fail "$EXIT_CLEANUP" 'WORKTREE_REMOVE_FAILED' "無法移除 worktree：$worktree_path"
        fi
    fi

    progress "刪除 branch：$branch"
    if ! git -C "$repo_root" branch -d "$branch" >&2; then
        fail "$EXIT_CLEANUP" 'BRANCH_DELETE_FAILED' "無法刪除 branch：$branch"
    fi

    worktree_runtime_dir="$project_dir/.opencode/$branch"
    if [[ -d "$worktree_runtime_dir" ]]; then
        progress "移除 OpenCode sandbox runtime：$worktree_runtime_dir"
        if ! rm -rf -- "$worktree_runtime_dir"; then
            record_cleanup_warning "無法移除 OpenCode sandbox runtime：$worktree_runtime_dir"
        fi
    fi
}

list_branches() {
    local -a branches=()
    local branch
    local branch_tip
    local worktree_path
    local current=false
    local entries_json

    mapfile -t branches < <(git -C "$repo_root" for-each-ref --format='%(refname:short)' refs/heads)

    if "$json"; then
        entries_json="$({
            for branch in "${branches[@]}"; do
                worktree_path="$(worktree_path_for_branch "$branch")"
                branch_tip="$(git -C "$repo_root" rev-parse --verify "$branch^{commit}")"
                current=false
                [[ "$branch" == "$current_branch" ]] && current=true
                jq -cn --arg branch "$branch" --arg tip "$branch_tip" --arg worktree "$worktree_path" --argjson current "$current" \
                    '{branch: $branch, tip: $tip, worktree: (if $worktree == "" then null else $worktree end), current: $current}'
            done
        } | jq -s .)"
        jq -cn \
            --arg project "$project" \
            --arg repository "$repo_root" \
            --arg current_branch "$current_branch" \
            --argjson branches "$entries_json" \
            '{status: "OK", command: "list", project: $project, repository: $repository,
              current_branch: (if $current_branch == "" then null else $current_branch end), branches: $branches}'
    else
        printf '%-30s %-60s %s\n' 'BRANCH' 'WORKTREE' 'CURRENT'
        for branch in "${branches[@]}"; do
            worktree_path="$(worktree_path_for_branch "$branch")"
            [[ -n "$worktree_path" ]] || worktree_path='-'
            current=false
            [[ "$branch" == "$current_branch" ]] && current=true
            printf '%-30s %-60s %s\n' "$branch" "$worktree_path" "$current"
        done
    fi
}

show_status() {
    local repo_status
    local -a changes=()
    local merge_conflict=false
    local changes_json

    repo_status="$(git -C "$repo_root" status --short)"
    if [[ -n "$repo_status" ]]; then
        mapfile -t changes <<<"$repo_status"
    fi
    git -C "$repo_root" rev-parse --verify --quiet MERGE_HEAD >/dev/null && merge_conflict=true || true

    if "$json"; then
        changes_json="$(json_array "${changes[@]}")"
        jq -cn \
            --arg project "$project" \
            --arg repository "$repo_root" \
            --arg branch "$current_branch" \
            --arg worktree_root "$project_dir" \
            --argjson clean "$([[ -z "$repo_status" ]] && printf true || printf false)" \
            --argjson merge_conflict "$merge_conflict" \
            --argjson changes "$changes_json" \
            '{status: "OK", command: "status", project: $project, repository: $repository,
              branch: (if $branch == "" then null else $branch end), clean: $clean,
              merge_conflict: $merge_conflict, changes: $changes, worktree_root: $worktree_root}'
    else
        printf 'Project: %s\nRepository: %s\nBranch: %s\nClean: %s\nMerge conflict: %s\nWorktree root: %s\n' \
            "$project" "$repo_root" "${current_branch:-detached HEAD}" \
            "$([[ -z "$repo_status" ]] && printf true || printf false)" "$merge_conflict" "$project_dir"
        if ((${#changes[@]} > 0)); then
            printf 'Changes:\n'
            printf '%s\n' "${changes[@]}"
        fi
    fi
}

run_interactive_add() {
    local branch

    reset_add_options
    add_wait=false
    branch="$(gum input --header "從 $current_branch 建立新 worktree" --placeholder 'feature/name')" || return
    [[ -n "$branch" ]] || return

    printf '\nBranch: %s\nWorktree: %s\n\n' "$branch" "$project_dir/$branch"
    gum confirm '確認建立？' || return
    add_branch "$branch"
}

run_interactive_merge() {
    local branches
    local selected
    local -a selected_branches=()
    local branch
    local cleanup_performed=false

    branches="$(git -C "$repo_root" for-each-ref --format='%(refname:short)' refs/heads | grep -Fxv "$current_branch" || true)"
    [[ -n "$branches" ]] || {
        printf '沒有其他本地 branch\n'
        return
    }

    selected="$(printf '%s\n' "$branches" | gum filter --no-limit --height 15 --header "選擇要合併到 $current_branch 的 branch")" || return
    [[ -n "$selected" ]] || return
    mapfile -t selected_branches <<<"$selected"

    printf '\n將依序合併到 %s：\n' "$current_branch"
    printf '%s\n' "$selected" | sed 's/^/  - /'
    printf '\n'
    gum confirm '開始合併？' || return

    merge_delete=false
    for branch in "${selected_branches[@]}"; do
        [[ -n "$branch" ]] || continue
        merge_branches "$current_branch" "$branch"
        gum confirm "刪除 $branch 及其 worktree？" || continue
        cleanup_branch "$branch"
        cleanup_performed=true
    done

    "$cleanup_performed" && git -C "$repo_root" worktree prune >&2
}

run_interactive() {
    require_command gum
    initialize_repository
    require_current_branch

    while true; do
        printf 'Project: %s\nCurrent branch: %s\nWorktree root: %s\n\n' "$project" "$current_branch" "$project_dir"
        action="$(gum choose 'add    建立 branch、worktree、Herdr workspace 和 OpenCode session' 'merge  選擇並合併 branch' 'quit   離開')" || exit 0
        clear
        case "$action" in
        add*) run_interactive_add ;;
        merge*) run_interactive_merge ;;
        *) exit 0 ;;
        esac
        printf '\n'
    done
}

run_add_command() {
    local branch=''

    reset_add_options
    while (($# > 0)); do
        if parse_global_option "$1" "${2-}"; then
            shift "$PARSED_COUNT"
            continue
        fi
        case "$1" in
        --base)
            [[ -n "${2-}" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' '--base 需要 ref 參數'
            add_base="$2"
            shift 2
            ;;
        --agent)
            [[ -n "${2-}" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' '--agent 需要名稱參數'
            add_agent="$2"
            shift 2
            ;;
        --prompt)
            [[ -z "$add_prompt_file" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' '--prompt 和 --prompt-file 不能同時使用'
            [[ -n "${2-}" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' '--prompt 需要文字參數'
            add_prompt="$2"
            add_prompt_provided=true
            shift 2
            ;;
        --prompt-file)
            ! "$add_prompt_provided" || fail "$EXIT_USAGE" 'USAGE_ERROR' '--prompt 和 --prompt-file 不能同時使用'
            [[ -n "${2-}" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' '--prompt-file 需要路徑參數'
            add_prompt_file="$2"
            shift 2
            ;;
        --title)
            [[ -n "${2-}" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' '--title 需要文字參數'
            add_title="$2"
            shift 2
            ;;
        --session)
            add_session=true
            shift
            ;;
        --no-session)
            add_session=false
            shift
            ;;
        --wait)
            add_wait=true
            shift
            ;;
        --detach)
            add_wait=false
            shift
            ;;
        --*) fail "$EXIT_USAGE" 'USAGE_ERROR' "未知選項：$1" ;;
        *)
            [[ -z "$branch" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' 'add 只能接受一個 branch'
            branch="$1"
            shift
            ;;
        esac
    done
    require_jq_for_json
    initialize_repository
    add_branch "$branch"
}

run_merge_command() {
    local target=''
    local -a branches=()
    local merge_keep=false

    merge_delete=false
    while (($# > 0)); do
        if parse_global_option "$1" "${2-}"; then
            shift "$PARSED_COUNT"
            continue
        fi
        case "$1" in
        --target)
            [[ -n "${2-}" ]] || fail "$EXIT_USAGE" 'USAGE_ERROR' '--target 需要 branch 參數'
            target="$2"
            shift 2
            ;;
        --delete)
            "$merge_keep" && fail "$EXIT_USAGE" 'USAGE_ERROR' '--delete 和 --keep 不能同時使用'
            merge_delete=true
            shift
            ;;
        --keep)
            "$merge_delete" && fail "$EXIT_USAGE" 'USAGE_ERROR' '--delete 和 --keep 不能同時使用'
            merge_keep=true
            shift
            ;;
        --*) fail "$EXIT_USAGE" 'USAGE_ERROR' "未知選項：$1" ;;
        *)
            branches+=("$1")
            shift
            ;;
        esac
    done
    require_jq_for_json
    initialize_repository
    target="${target:-$current_branch}"
    merge_branches "$target" "${branches[@]}"
}

main() {
    if (($# == 0)); then
        run_interactive
        return
    fi

    while (($# > 0)); do
        if parse_global_option "$1" "${2-}"; then
            shift "$PARSED_COUNT"
            continue
        fi
        command_name="$1"
        shift
        break
    done

    [[ -n "$command_name" ]] || {
        usage >&2
        exit "$EXIT_USAGE"
    }
    require_jq_for_json

    case "$command_name" in
    add) run_add_command "$@" ;;
    merge) run_merge_command "$@" ;;
    list)
        while (($# > 0)); do
            if parse_global_option "$1" "${2-}"; then
                shift "$PARSED_COUNT"
            else
                fail "$EXIT_USAGE" 'USAGE_ERROR' "未知選項：$1"
            fi
        done
        require_jq_for_json
        initialize_repository
        list_branches
        ;;
    status)
        while (($# > 0)); do
            if parse_global_option "$1" "${2-}"; then
                shift "$PARSED_COUNT"
            else
                fail "$EXIT_USAGE" 'USAGE_ERROR' "未知選項：$1"
            fi
        done
        require_jq_for_json
        initialize_repository
        show_status
        ;;
    *)
        fail "$EXIT_USAGE" 'USAGE_ERROR' "未知子命令：$command_name"
        ;;
    esac
}

main "$@"
