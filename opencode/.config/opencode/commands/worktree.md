---
description: Interpret and confirm worktree add, list, status, and merge requests.
agent: worktree
subtask: false
---

Interpret this request as add, list, status, or merge. Clarify material ambiguity
and use only the local helper script for validation and execution:

$ARGUMENTS

Use only the local helper script after confirmation for mutating operations. Do
not inspect project files, implement code, create an implementation plan,
alter explicit branch names, or run additional Git commands. Only a verified
`MERGE_CONFLICT` may dispatch the hidden `worktree-merge-resolver`.
