---
name: core-ui-visual-review
description: Use when reviewing or fixing a UI from a runtime screenshot, browser snapshot, or visible Desktop window region.
---

# UI Visual Review

Use runtime evidence before making visual-completion claims. This skill routes
Web, Desktop, and supplied-image review; it does not replace implementation,
visual design, accessibility, responsive, interaction, or Dioxus guidance.

## Evidence

- Classify every conclusion as screenshot confirmed, browser snapshot confirmed,
  code inferred, or runtime verification required.
- A code-only review must not be described as a visual review.
- After a visual fix, require fresh runtime evidence before claiming it works.
- Read the relevant RSX, CSS, and local conventions after obtaining evidence.
- Do not route a bare URL or an otherwise malformed command target. It is
  `BLOCKED: INVALID_TARGET`, not implicit consent to navigate.

## Platform Routing

- For a supplied image, require an absolute PNG, JPEG, WebP, or GIF path, read
  it directly, and state its provenance if known. It confirms only its visible
  static state; interaction and responsive conclusions require runtime evidence.
- For a Web URL, use the scoped browser tools. Obtain a browser snapshot before
  choosing selectors; use a screenshot for visual assessment and console output
  for runtime errors.
- For Desktop, use the scoped screenshot tool with an exact class, title, and/or
  ephemeral address selector. Call `ui_window_match` first, then use
  `ui_screenshot` only for a unique match. It captures only the visible screen region occupied by a
  uniquely matched window; it cannot capture content obscured by another
  window. `desktop` is an explicit opt-in to `ui_window_list`, which may reveal
  window titles and returns copyable selectors. It is discovery only: reproduce
  its full result in the final response and label it `DISCOVERY_COMPLETE`, not
  a visual-review state. Immediately read the PNG path
  returned by `ui_screenshot` before assessing the UI. Desktop evidence is
  stored under a tool-private `$XDG_RUNTIME_DIR/opencode-ui-review/` directory.
  Do not use Bash as a fallback. A readable visible-region capture is verified
  within that scope; only unreadable, absent, or materially limited evidence is
  partial or blocked.
- Do not launch a browser server or application. Request the user to provide a
  running target or explicitly approve a project-specific launch action.

## Review Scope

- Load `core-dioxus-07` only for a Dioxus 0.7 project.
- Load only the needed specialist skill: visual foundations for hierarchy,
  typography, color, or spacing; responsive design for resizing/reflow;
  accessibility for semantics, focus, or contrast; interaction design for
  state feedback; design-system patterns for reusable UI foundations.
- Report findings first, ordered High, Medium, Low. Use one result state:
  `VERIFIED_REVIEW`, `PARTIAL_REVIEW`, or `BLOCKED: <reason>`. Include concrete evidence,
  impact, a minimal fix, and `file:line` references for code-backed findings.
- Treat `ERR_BLOCKED_BY_CLIENT.Inspector` as an inspector limitation rather
  than a product defect. Mark the result `PARTIAL_REVIEW` if it affects visual
  evidence.
- If a Dioxus rebuild or loading overlay remains after a bounded wait, capture
  a screenshot before deciding whether to block. Return
  `BLOCKED: RUNTIME_STATE` only when the screenshot confirms that primary
  content is obscured; treat a non-blocking toast as a runtime note.

## Fix Mode

- Without `--fix`, do not request edits.
- With `--fix`, require an explicit source path, capture baseline evidence, make
  only approved edits, wait for the target's existing reload behavior, then
  capture fresh evidence.
- Return `BLOCKED: RELOAD_UNVERIFIED` if the target does not visibly reload or
  fresh evidence is unavailable; do not claim a fix is verified.
