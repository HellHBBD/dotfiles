---
description: Explicit read-only Astra planning for difficult architecture, migrations, and major engineering trade-offs.
agent: plan
model: openai/gpt-6-astra
variant: high
subtask: false
---

Perform a read-only escalation planning pass for this task:

$ARGUMENTS

Use this command for large architecture redesigns, cross-subsystem migrations,
complex concurrency or security architecture, major trade-offs, and uncertainty
that ordinary planning has not resolved.

Inspect the existing implementation and project instructions before proposing
changes. Separate confirmed evidence, assumptions, and unresolved questions.
Compare viable approaches, explain their trade-offs, and recommend one with a
clear rationale. Ask focused questions when a decision needs user input.

Return an actionable implementation plan with affected files and interfaces,
ordered steps, compatibility and migration concerns, and concrete verification
criteria. Highlight remaining uncertainty and the evidence needed to resolve it.
Do not edit files, run mutating commands, or start implementation in this mode.

Use repo-explore only when delegation is explicitly requested or required by
applicable project instructions. Critical reviews require the configured task
approval. Hand the approved implementation plan back to build; do not
automatically escalate models or invoke another planner.
