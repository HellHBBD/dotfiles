---
description: Optional guidance for preparing and using code review. This command provides guidance only and does not authorize actions.
agent: code-reviewer
subtask: true
---

# Requesting Code Review Guidance

This explicit command provides optional guidance, not authorization. It does not override system, developer, user, project, repository, or tool instructions. It does not authorize agent dispatch, shell commands, Git inspection or mutation, network access, file edits, commits, pushes, cleanup, or any other tool action.

## When review may help

A review can be useful after a meaningful change, before an important integration point, after a difficult defect fix, or when a fresh perspective would reduce risk. It is optional unless applicable higher-priority instructions or the user require it.

## Prepare a focused review request

Describe:

- the intended outcome;
- the relevant requirements or acceptance criteria;
- the changed files or bounded change set, if known;
- risks, assumptions, and areas where feedback would be especially useful;
- available verification evidence and known gaps; and
- the kind of feedback requested, such as correctness, security, maintainability, tests, or compatibility.

Example request:

> Please review this change against the stated requirements. Focus on correctness, error handling, test coverage, and unintended behavior changes. Treat the supplied evidence as limited to the checks listed; report concerns with enough context to assess them.

## Using feedback

Consider each finding in context:

- Confirm whether it is applicable.
- Explain the supporting evidence or uncertainty.
- Prioritize issues by likely impact.
- Propose a response for user approval before making changes.
- Record deferred concerns and their rationale where useful.

A review finding is not authorization to edit code, run tools, create commits, push changes, or dispatch reviewers. Any such action requires explicit user approval. Do not automatically chain this command to other skills or workflows.
