---
name: vendor-anthropics-webapp-testing
description: Use when testing a running local Web UI through the scoped Playwright MCP browser tools, screenshots, snapshots, and console output.
license: Apache-2.0
---

# Web Application Testing

Adapted from `anthropics/skills` `skills/webapp-testing` at
`b29e7cf65e5cb78a5ac33d582270551bc74a14eb`.

Use the scoped Playwright MCP tools rather than native Python Playwright
scripts. This derivative intentionally excludes upstream helper scripts,
examples, and server lifecycle management.

## Workflow

1. Work only with a running local URL supplied by the user or current task.
2. Navigate only after permission approval, then wait for rendered state.
3. Capture an accessibility snapshot before choosing interactive targets.
4. Use snapshot/find for structure and screenshots for visual verification.
5. Inspect console messages when diagnosing client-side errors.
6. After a UI change, wait for existing hot reload or rebuild behavior and
   capture fresh evidence before reporting a fix as verified.

## Boundaries

- Do not start or stop a server or app.
- Do not use arbitrary page evaluation, unsafe code execution, uploads, or
  file drops.
- Treat clicks, typing, keyboard input, navigation, and resize as runtime
  mutations that require approval.
- `browser_wait_for` is intentionally allowed despite upstream marking it
  non-read-only; it only waits for time or rendered text in this configuration.
