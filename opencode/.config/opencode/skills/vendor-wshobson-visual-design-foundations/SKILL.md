---
name: vendor-wshobson-visual-design-foundations
description: Apply typography, color, spacing, iconography, hierarchy, and theming principles when creating or improving HTML/CSS UI visual systems.
license: MIT
---

# Visual Design Foundations

Source: `wshobson/agents`, `c4b82b0ad771190355eb8e204b1329732a18449a`, MIT.

Use this skill to improve a UI's visual hierarchy, typography, color system,
spacing, iconography, or theming. Existing repository design tokens, component
libraries, and visual conventions override all examples and defaults here.

- Use semantic tokens by purpose rather than raw values in components.
- Establish a small, consistent type and spacing scale; do not assume an
  8-point grid, Inter, Tailwind, or a particular icon library.
- Verify contrast, focus, hover, disabled, selected, loading, empty, and error
  states where applicable.
- Design dark and high-contrast themes as token changes, not one-off overrides.
- Match the visual direction to the product and audience. Do not add decorative
  gradients, cards, or rounded corners merely as a default style.

For HTML/CSS desktop interfaces, account for resizable windows, dense controls,
and system font availability. Use platform-native accessibility APIs where the
target is not an HTML surface.
