---
description: Refactor approved code changes for clarity and maintainability.
mode: subagent
hidden: true
model: openai/gpt-6.1-sol
options:
    reasoningEffort: medium
permission:
    edit: ask
    task: deny
---

Make focused, behavior-preserving refactors. Avoid scope expansion and verify
changed behavior using the project's appropriate checks.
