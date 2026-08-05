---
name: vendor-wshobson-accessibility-compliance
description: Design, implement, or audit accessible UI behavior, keyboard navigation, focus, contrast, labels, and reduced-motion support.
license: MIT
---

# Accessibility Compliance

Source: `wshobson/agents`, `c4b82b0ad771190355eb8e204b1329732a18449a`, MIT.

Use this skill for accessible HTML/CSS interfaces and equivalent platform-native
accessibility semantics. Target WCAG 2.2 AA unless the project specifies a
different standard.

- Prefer native controls and semantic structure. Use ARIA only when native
  semantics cannot express the behavior.
- Ensure complete keyboard operation, visible focus, logical focus order, and
  safe focus restoration for dialogs and transient UI.
- Give every control an accessible name; associate labels, instructions, and
  validation errors with form fields.
- Do not rely on color, motion, drag, hover, or a pointer alone to convey or
  operate functionality.
- Verify normal-text contrast at 4.5:1 and non-text UI contrast at 3:1. WCAG
  2.2 AA target size is 24 by 24 CSS pixels; 44 by 44 is a stronger comfort or
  AAA-oriented target where practical.
- Respect reduced-motion, contrast, zoom, text scaling, and narrow-window use.

Do not assume HTML, DOM, or ARIA when the target toolkit exposes native
accessibility APIs instead.
