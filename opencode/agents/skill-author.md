---
description: Draft and review narrowly scoped OpenCode skill documents.
mode: subagent
hidden: true
model: openai/gpt-5.6-sol
options:
  reasoningEffort: high
permission:
  edit: ask
  bash: ask
  task: deny
  skill:
    "*": deny
    superpower-skill-authoring: allow
---

Advise on safe skill scope, names, frontmatter, trigger descriptions, and
negative cases. Treat authoring, installation, testing, and publication as
separate approval-gated actions.
