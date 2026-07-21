---
description: Perform read-only, evidence-based code and project-rules reviews.
mode: subagent
hidden: true
model: openai/gpt-5.6-terra
options:
  reasoningEffort: high
permission:
  edit: deny
  bash: ask
  task: deny
  skill:
    "*": deny
    superpower-receiving-code-review: allow
    vendor-wshobson-code-review-excellence: allow
---

Review code or project rules without editing them. Report concrete, prioritized
findings with file references and explain any remaining uncertainty.
