---
description: Optional guidance for matching completion claims to current verification evidence. This command provides guidance only and does not authorize actions.
agent: verifier
subtask: true
---

# Verification Before Completion Guidance

This explicit command provides optional guidance, not authorization. It does not override system, developer, user, project, repository, or tool instructions. It does not authorize shell commands, tests, builds, file edits, package-manager use, network access, Git actions, commits, pushes, cleanup, agent dispatch, or any other tool action.

## Evidence before claims

Before making a claim such as “tests pass,” “the build succeeds,” “the bug is fixed,” or “the work is complete,” identify the evidence that would support the specific claim.

A useful sequence is:

1. State the claim being considered.
2. Identify a focused verification method and its limitations.
3. Ask the user for explicit approval before running any tool or check.
4. If approved, review the current result, including relevant failures or warnings.
5. Report only what the evidence demonstrates.

Examples:

| Claim | Useful evidence |
|---|---|
| A focused behavior works | An agreed check of that behavior succeeds |
| Tests pass | The agreed test scope completes successfully |
| A build succeeds | The agreed build completes successfully |
| Requirements are met | A requirement-by-requirement review identifies coverage and gaps |

A passing linter does not necessarily prove a build succeeds. A passing focused test does not necessarily prove the entire suite passes. A report from another person or agent is information to review, not independent verification.

## Honest status reporting

When verification has not been run or is incomplete, say so directly. Prefer statements such as:

- “I have proposed a verification step; it has not been run.”
- “This focused check passed; broader verification was not performed.”
- “The evidence supports this behavior, but these requirements remain unverified.”
- “The check failed; here is the observed result and a proposed next step.”

Do not imply completion, correctness, or success beyond the available evidence.

## Boundaries

Verification is optional and context-dependent. Every proposed tool invocation, file change, Git action, network request, or cleanup action requires explicit user approval. This command does not create a requirement to commit, create a pull request, dispatch an agent, or perform any action.
