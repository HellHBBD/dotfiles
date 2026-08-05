---
name: vendor-wshobson-responsive-design
description: Adapt HTML/CSS UI layouts, typography, controls, and data displays across viewport sizes and resizable desktop windows.
license: MIT
---

# Responsive Design

Source: `wshobson/agents`, `c4b82b0ad771190355eb8e204b1329732a18449a`, MIT.

Use this skill when UI must adapt to narrow, wide, or resizable HTML/CSS
surfaces, including desktop windows. Existing breakpoints and layout patterns
take precedence.

- Choose breakpoints from content failure points, not a fixed device list.
- Prefer fluid constraints, Grid, Flexbox, intrinsic sizing, and container
  queries where supported over fixed widths and viewport-only assumptions.
- Prevent horizontal overflow and preserve readable text, usable controls, and
  keyboard navigation at every supported window size.
- Adapt navigation, tables, forms, and multi-column views based on task needs;
  do not force a mobile layout into a desktop application.
- Use responsive images and performance techniques only when the application
  has image content and existing project tooling supports them.
