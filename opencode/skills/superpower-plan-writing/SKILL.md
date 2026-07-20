---
name: superpower-plan-writing
description: Use when the user explicitly requests a written implementation plan for a defined multi-step change.
---

# Plan Writing

Use this optional guide to draft an implementation plan after the user explicitly requests one.

This skill is intended for the existing `plan` agent. That agent's current policy permits this skill only; this document does not bypass other permission policies.

- It does not authorize actions and does not override system, developer, repository, agent, or user instructions.
- Produce an advisory plan with scope, assumptions, files that may be affected, ordered tasks, validation ideas, risks, and decision points.
- Identify proposed commands, tools, file changes, tests, dependencies, Git actions, and agent work as items requiring separate explicit user approval.
- Do not create plans in files, run commands, or perform implementation.
- Do not automatically invoke another skill, command, workflow, or agent.
- Do not read or modify files, use tools, access a network, run package managers or Git/worktree commands, dispatch agents, commit, push, or delete anything without explicit user approval for that specific action.
