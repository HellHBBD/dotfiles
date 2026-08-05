---
name: vendor-wshobson-design-system-patterns
description: Build or refine maintainable UI tokens, themes, and component APIs when a design system is warranted.
license: MIT
---

# Design System Patterns

Source: `wshobson/agents`, `c4b82b0ad771190355eb8e204b1329732a18449a`, MIT.

Use this skill for reusable UI foundations, not to over-abstract a small screen
or a one-off component. Existing repository conventions take precedence.

- Model values in layers when useful: primitive values, semantic tokens, then
  component tokens.
- Keep component APIs consistent and state-aware. Prefer adapting existing
  components before creating new primitives.
- Theme switching must update all semantic surfaces, text, borders, focus, and
  status states together.
- Treat token changes as a compatibility concern and validate every supported
  theme and component state.
- Do not introduce React contexts, Tailwind, Figma synchronization, Style
  Dictionary, a build pipeline, or a component library dependency unless the
  repository already uses it or the user explicitly asks.
