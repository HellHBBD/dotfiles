---
description: Clarify, execute, review, and integrate a queue of development tasks using isolated Git worktrees.
agent: queue-orchestrator
subtask: false
---

Process this task queue request:

$ARGUMENTS

Supported forms are a multiline task list, a broad objective to decompose,
`status <queue-id>`, and `resume <queue-id>`.

For a new queue, inspect repository and Git state; normalize tasks; identify
dependencies, overlap, risks, and validation; collect every material ambiguity;
ask one consolidated question round; then present a complete Queue Freeze. Do
not create branches, worktrees, or workers until every unresolved item is empty
and the Queue Freeze has explicit approval.

After approval, execute safe dependency waves; review and verify every task;
integrate accepted task branches into the integration branch; run full
integration verification; and request the final fast-forward-only merge through
the permission prompt.

This command invocation alone does not authorize Queue Freeze, worktrees,
subagents, final merge, push, deploy, force operations, or destructive cleanup.

Defaults:

- base branch and commit: current branch and HEAD;
- queue root: `~/.local/share/opencode/task-queues/`;
- maximum parallel workers: 3;
- uncertain overlap: sequential;
- repair rounds: 2 per task;
- final merge: explicit `git merge --ff-only` approval;
- push and force operations: prohibited;
- post-success cleanup: clean worktrees and normally merged queue branches only;
- post-failure cleanup: preserve state.

Queue Freeze must include queue ID, base branch/commit, tasks and criteria,
non-goals, dependencies, waves, expected file ownership, workers, validation,
review policy, merge order, risks, unresolved items, and later approval points.
