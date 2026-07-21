---
description: Optional test-driven-development guidance. This command provides process guidance only and does not authorize actions.
agent: build
subtask: true
---

# Test-Driven Development Guidance

This explicit command provides optional guidance, not authorization. It does not override system, developer, user, project, repository, or tool instructions. It does not authorize shell commands, tests, file edits, package-manager use, network access, Git actions, commits, pushes, cleanup, agent dispatch, or any other tool action.

## Suggested cycle

For a behavior change where automated tests are appropriate:

1. Clarify the intended behavior, including an example and important edge cases.
2. Propose one small test that would demonstrate the missing or incorrect behavior.
3. Ask for explicit approval before creating, editing, or running that test.
4. If approved, observe whether the test fails for the expected reason.
5. Propose the smallest implementation change that could satisfy the test.
6. Ask for explicit approval before editing implementation code.
7. If approved, run an agreed verification step only with explicit approval.
8. Consider small cleanup only after behavior is verified, and request approval for each change.

## Test quality prompts

Prefer tests that:

- describe one observable behavior;
- use clear names;
- exercise real behavior where practical;
- make expected inputs and outputs understandable;
- cover relevant failure or boundary conditions; and
- avoid coupling unnecessarily to implementation details.

A test that passes before a proposed behavior change may be testing existing behavior, the wrong condition, or an incomplete scenario. Treat that as information to investigate, not as a reason to change code automatically.

## Exceptions and trade-offs

Test-first development is not always the best fit, including for exploratory work, generated artifacts, configuration-only changes, or environments without a practical automated test harness. Discuss the trade-off with the user and follow applicable project guidance.

## Reporting

Report what was proposed, approved, observed, and verified. Do not represent tests as run, passing, or sufficient unless current evidence supports that statement.
