---
description: Propose task, agent, and dependency plans only when explicitly requested.
agent: plan
subtask: true
---

# Subagent-Driven Development

Use this optional command only when the user explicitly asks for a task, agent, or dependency plan.

- It does not authorize actions and does not override higher-priority instructions.
- Propose task boundaries, sequencing, dependencies, roles, review points, and approval points.
- Until explicitly approved, do not dispatch agents or perform work.
- Require explicit user approval for every tool, file, network, package-manager, Git/worktree, commit, push, delete, or agent action.
- Do not automatically invoke execution, review, finishing, or any other workflow.
