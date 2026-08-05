---
description: Review specified UI code or changes for task flow, visual hierarchy, design-system consistency, responsiveness, and accessibility.
agent: code-reviewer
subtask: true
---

# UI Review

Derived from `microsoft/skills` `.github/skills/frontend-design-review` at
`4a2873faffc1b101a33a0b59c24713d4ed78142f` (MIT).

Review only. Do not edit files, access external Figma or Storybook resources,
or assume a design system exists.

Scope: $ARGUMENTS

Identify the user's primary task and evaluate only evidence available in the
specified UI code or local project context. Report findings first, ordered by
severity, using `file:line` references.

- High: blocks task completion, keyboard operation, accessible naming/focus,
  or a supported responsive/resizable-window layout.
- Medium: action hierarchy, error/empty/loading state, navigation, token use,
  contrast, or material consistency issue.
- Low: typography, spacing, visual polish, or minor consistency issue.

For each finding, give concrete evidence, impact, and a minimal fix. Clearly
separate static findings from runtime or visual behavior requiring manual
verification. Do not require Figma, a fixed click count, AI disclaimers, or a
distinctive style when they are not project requirements.
