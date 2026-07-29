---
description: Run the local worktree helper script.
agent: build
subtask: false
---

Run the user's requested `worktree.sh` command and report its result. Do not
plan, inspect project files, implement code, or replace the script's workflow.

Arguments:

`$ARGUMENTS`

If arguments are present, invoke `$HOME/shs/worktree.sh` with those arguments.
If no arguments are present, invoke `$HOME/shs/worktree.sh --help`; do not open
the interactive Gum UI from this command. Preserve the script's exit status and
stdout. Do not add `--yes`, alter arguments, or run additional Git commands.
