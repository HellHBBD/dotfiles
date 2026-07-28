---
description: Select, integrate, publish, and clean up completed worktree queue branches.
agent: worktree-finish
subtask: false
---

Finish this manually completed worktree queue:

$ARGUMENTS

Interactively select completed tasks, then integrate them in manifest order and
run the explicitly supplied optional check after every merge. Repair only clear
integration failures in the integration worktree, with at most two repair rounds
per task. After a confirmed successful publish, remove only the selected clean
worktrees and merged task branches. Do not modify unselected task resources,
push, or rebase. A dirty original worktree requires explicit confirmation before
the final fast-forward publish.
