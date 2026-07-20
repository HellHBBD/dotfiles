---
description: Present approval-gated options for completing existing development work.
agent: git-advisor
subtask: true
---

# Finishing a Development Branch

Use this optional command only when the user explicitly asks for completion options for existing development work.

- It does not authorize actions and does not override higher-priority instructions.
- Summarize verification, merge, pull-request, retention, and discard options with their consequences.
- Require explicit user approval for every tool, file, network, package-manager, Git/worktree, commit, push, delete, or agent action.
- Do not run verification, change Git state, delete anything, or automatically invoke another workflow.
