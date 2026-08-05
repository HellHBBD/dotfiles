---
description: Produce a read-only UI/UX design proposal with distinct visual directions and implementation constraints.
agent: plan
subtask: true
---

# UI Design Proposal

Derived from `anthropics/skills` `skills/frontend-design` at
`b29e7cf65e5cb78a5ac33d582270551bc74a14eb` (Apache-2.0).

Create a design proposal only. Do not edit files, install dependencies, take
screenshots, or persist notes.

Target: $ARGUMENTS

Load `vendor-wshobson-visual-design-foundations`,
`vendor-wshobson-responsive-design`, and
`vendor-wshobson-interaction-design` before proposing directions. Load
`vendor-wshobson-design-system-patterns` only when the proposal needs reusable
UI foundations or component APIs.

1. Read the relevant existing UI, design tokens, and project conventions.
2. State the user, the task, and the constraints. If evidence is absent, mark
   assumptions rather than inventing product facts.
3. Present two or three context-specific directions. For each include visual
   rationale, typography, palette/tokens, layout, responsive window behavior,
   state/interaction behavior, accessibility considerations, and tradeoffs.
4. Recommend one direction and identify the smallest implementation scope.

Existing project conventions override imported guidance. Avoid generic visual
defaults and decorative motion. Finish with a proposal awaiting user approval;
do not implement it.
