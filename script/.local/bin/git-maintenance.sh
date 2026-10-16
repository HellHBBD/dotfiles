#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf '%s\n' \
        'Usage: git-maintenance.sh [--dry-run] [--threads N] [--timeout SECONDS] [--] [DIRECTORY ...]' \
        'Scan HOME by default; maintain each common Git directory once, sequentially.' \
        'Defaults: 2 packing threads, 120 seconds for the entire scan and maintenance.' \
        'The configured Git maintenance tasks and cleanup policy are preserved.'
}

fail() {
    printf 'git-maintenance.sh: %s\n' "$*" >&2
    exit 2
}

threads=2
time_limit=120
dry_run=0
roots=()
while (($#)); do
    case "$1" in
    --dry-run)
        dry_run=1
        shift
        ;;
    --threads | --timeout)
        [[ "${2-}" =~ ^[1-9][0-9]*$ ]] || fail "$1 requires a positive integer"
        if [[ "$1" == --threads ]]; then
            threads="$2"
        else
            time_limit="$2"
        fi
        shift 2
        ;;
    --help | -h)
        usage
        exit 0
        ;;
    --)
        shift
        roots+=("$@")
        break
        ;;
    -*) fail "unknown option: $1" ;;
    *)
        roots+=("$1")
        shift
        ;;
    esac
done
((${#roots[@]})) || roots=("${HOME:?HOME must be set}")

for dependency in guard-run timeout python3 git; do
    command -v "$dependency" >/dev/null 2>&1 || fail "missing dependency: $dependency"
done

# Guard the whole batch, including discovery. Keep Git in the foreground so
# detached maintenance cannot outlive the timeout or escape error reporting.
exec guard-run --jobs "$threads" --cpu-quota "${threads}00%" \
    --memory-high 2G --memory-max 4G --swap-max 512M -- \
    timeout --signal=TERM --kill-after=10s "${time_limit}s" \
    python3 - "$threads" "$dry_run" "${roots[@]}" <<'PY'
import os
import subprocess
import sys

threads, dry_run = sys.argv[1:3]
roots = list(dict.fromkeys(os.path.realpath(path) for path in sys.argv[3:]))
errors = 0
seen = set()
succeeded = 0


def report_error(message):
    global errors
    errors += 1
    print(f"git-maintenance.sh: {message}", file=sys.stderr, flush=True)


def query(repo, *args):
    result = subprocess.run(
        ["git", "-C", repo, *args], capture_output=True,
        text=True, errors="surrogateescape", check=False,
    )
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or f"Git exited {result.returncode}")
    # Remove Git's output terminator without stripping whitespace from a path.
    return result.stdout.removesuffix("\n")


def maintain(repo):
    global succeeded
    try:
        common = os.path.realpath(query(
            repo, "rev-parse", "--path-format=absolute", "--git-common-dir",
        ))
    except RuntimeError as error:
        report_error(f"cannot inspect {repo!r}: {error}")
        return
    if common in seen:
        return
    seen.add(common)
    print(f"{'Would maintain' if dry_run == '1' else 'Running maintenance in'} {repo!r}", flush=True)
    if dry_run == "1":
        return
    result = subprocess.run([
        "git", "-C", repo, "-c", f"pack.threads={threads}",
        "-c", "maintenance.autoDetach=false", "-c", "gc.autoDetach=false",
        "maintenance", "run", "--no-detach",
    ], check=False)
    if result.returncode:
        report_error(f"maintenance failed in {repo!r} (exit {result.returncode})")
    else:
        succeeded += 1


try:
    for root in roots:
        if not os.path.isdir(root):
            report_error(f"not a directory: {root!r}")
            continue
        for directory, directories, files in os.walk(root, onerror=report_error):
            if ".git" in directories or ".git" in files:
                maintain(directory)
                if ".git" in directories:
                    directories.remove(".git")
            # Bare repositories have no .git marker. Verify before pruning their
            # metadata; do not confuse a project's unrelated HEAD file with Git.
            elif "HEAD" in files and "objects" in directories:
                try:
                    bare = query(directory, "rev-parse", "--is-bare-repository")
                except RuntimeError:
                    continue
                if bare == "true":
                    maintain(directory)
                    directories.clear()
except KeyboardInterrupt:
    sys.exit(130)
except OSError as error:
    report_error(error)

print(f"Repositories: {len(seen)}; completed: {succeeded}; errors: {errors}", flush=True)
sys.exit(1 if errors else 0)
PY
