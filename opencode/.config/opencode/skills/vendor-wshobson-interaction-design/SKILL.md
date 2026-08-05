---
name: vendor-wshobson-interaction-design
description: Improve UI feedback, loading, empty, error, focus, notification, and state-transition behavior without unnecessary animation.
license: MIT
---

# Interaction Design

Source: `wshobson/agents`, `c4b82b0ad771190355eb8e204b1329732a18449a`, MIT.

Use this skill to improve task feedback and state transitions. Motion must
communicate feedback, orientation, focus, or continuity; do not add it only for

- Make loading, success, error, empty, disabled, and interrupted states clear
  and actionable.
- Preserve interaction availability during transitions and provide cancellation
  or an alternative for long-running actions.
- Prefer the repository's existing framework primitives and CSS transitions.
  Do not add Framer Motion, GSAP, Lenis, or any animation dependency without
  explicit approval.
- Respect reduced-motion settings and ensure every interaction works without
  motion, hover, drag, or JavaScript animation.
- Prefer `transform` and `opacity` for short, purposeful animations. Avoid
  scroll hijacking, perpetual loops, and decorative parallax by default.
