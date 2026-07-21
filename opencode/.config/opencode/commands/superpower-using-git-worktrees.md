---
description: Optional guidance for discussing isolated workspaces and Git worktrees. This command provides guidance only and does not authorize actions.
agent: git-advisor
subtask: true
---

# Isolated Workspace and Git Worktree Guidance

This explicit command provides optional guidance, not authorization. It does not override system, developer, user, project, repository, or tool instructions. It does not authorize shell commands, Git inspection or mutation, worktree creation, branch creation, file edits, package-manager use, network access, commits, pushes, cleanup, or any other tool action.

## Purpose

An isolated workspace can reduce interference with unrelated work. Whether it is appropriate depends on the repository, platform, task, existing workspace state, and the user’s preferences.

## Discussion checklist

Before proposing an isolated workspace, clarify:

- whether isolation is needed for this task;
- whether the current workspace is already managed or isolated;
- the preferred location and naming convention;
- how dependencies, generated files, secrets, and uncommitted work would be handled;
- what verification is appropriate; and
- how the user wants any temporary workspace handled afterward.

Explain expected effects and risks before requesting authorization. Do not inspect repository state, create a worktree, change branches, modify ignore files, install dependencies, run setup, run tests, or remove anything unless the user explicitly approves each action.

## Safer proposal format

> I can propose an isolated-workspace plan. It would identify the intended location, branch strategy, setup needs, verification scope, and cleanup responsibility. No Git or filesystem action will occur unless you explicitly approve the specific action.

If the user declines isolation, continue only within the boundaries they specify. If the workspace is already isolated or externally managed, do not assume that it is safe to create nested worktrees or alter its state.

## Reporting

Clearly separate proposed actions from completed actions. Do not claim that a worktree exists, is clean, is configured, or has passing tests unless current approved evidence supports the claim.
