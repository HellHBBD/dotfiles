---
description: Clarify, execute, review, and integrate a queue of development tasks using isolated Git worktrees.
agent: queue-orchestrator
subtask: false
---

Process this task queue request:

$ARGUMENTS

Supported forms are a multiline task list, a broad objective to decompose,
`status <queue-id>`, and `resume <queue-id>`.

For a new queue, inspect repository and Git state; run only approved read-only
runtime probes; normalize tasks; identify dependencies, overlap, safety risks,
and validation; collect every material ambiguity; ask one consolidated question
round; then present a complete Queue Freeze. Prefer a clean base. A dirty base
requires explicit excluded paths with staged state and content hashes. Do not
create branches, worktrees, manifests, or workers until every unresolved item
is empty and the Queue Freeze has explicit approval.

After approval, atomically create queue metadata and its lock; create a
machine-readable manifest for each task; run a worker permission canary; then
execute safe dependency waves. Review and verify every task against its
manifest, preserving repair findings and separating infrastructure failures
from repair rounds. Integrate accepted task branches into the integration
branch, run full integration verification, request explicit partial acceptance
when tasks remain blocked, and request the final fast-forward-only merge through
the permission prompt.

This command invocation alone does not authorize Queue Freeze, worktrees,
subagents, final merge, push, deploy, force operations, or destructive cleanup.

Defaults:

- base branch and commit: current branch and HEAD;
- queue root: `~/.local/share/opencode/task-queues/`;
- maximum parallel workers: 3;
- uncertain overlap: sequential;
- repair rounds: 2 per task;
- infrastructure failures: `INFRA_BLOCKED`, no repair-round consumption;
- queue lock: atomic `.lock/` directory, with legacy `.lock` files preserved;
- final merge: explicit `git merge --ff-only` approval;
- push and force operations: prohibited;
- post-success cleanup: clean worktrees and normally merged queue branches only;
- post-failure cleanup: preserve state.

Queue Freeze must include queue ID, base branch/commit, tasks and criteria,
non-goals, dependencies, waves, expected file ownership, workers, validation,
review policy, merge order, risks, runtime-probe evidence, unresolved items,
and later approval points. Safety-critical tasks require a feasibility spike and
an explicit decision on any weaker semantics before implementation.
