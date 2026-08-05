---
description: Run a read-only WCAG 2.2 accessibility audit of specified UI code or paths.
agent: code-reviewer
subtask: true
---

# UI Accessibility Audit

Derived from `wshobson/agents` `plugins/ui-design/commands/accessibility-audit.md`
at `c4b82b0ad771190355eb8e204b1329732a18449a` (MIT), rewritten as a
read-only audit.

Target: $ARGUMENTS

Audit the provided path or UI scope against WCAG 2.2 AA by default. Do not
create `.ui-design/`, reports, state files, tests, or dependencies. Do not
modify code or enter guided-fix mode.

Report findings first with severity, WCAG criterion where applicable, and
`file:line` evidence. Check semantic structure, control names, labels and
errors, keyboard operation, focus, dialogs, contrast evidence, non-color
indicators, target sizes, reduced motion, and responsive reflow. Separate
static evidence from manual/runtime checks such as screen-reader output,
computed contrast, zoom, and real keyboard traversal. Apply platform-native
accessibility semantics when the UI is not HTML.
