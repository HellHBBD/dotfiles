---
description: Review a running Web or Desktop UI from runtime evidence; use --fix to request minimal verified fixes.
agent: ui-inspector
subtask: true
---

# Runtime UI Review

Target: $ARGUMENTS

Interpret `--fix` as permission to request code edits. Without `--fix`, review
only and do not request edits. Do not infer a target, selector, or source path.

Use `core-ui-visual-review` to route the target:

- Local running URL: use the scoped Playwright MCP browser tools.
- Desktop exact class/title/address selector: call `ui_window_match`, then
  `ui_screenshot` only for a unique match.
- `desktop`: explicitly call `ui_window_list` and show its copyable selectors.
- Image path: read the image directly.

Do not start a Dioxus app, web server, browser server, or Desktop app. If no
visual source is available, report the blocker instead of claiming visual
verification. Report findings first with evidence classification and code
references where applicable. In `--fix` mode, capture baseline evidence,
perform minimal edits, wait for existing reload behavior, and capture fresh
evidence before reporting the result.

Never replace scoped browser or Desktop tools with Bash commands. Accept only:

```text
/ui-review web url="http://localhost:8080"
/ui-review desktop
/ui-review window class="exact-class" [title="Exact title"] [address="0x1234abcd"] [source="/absolute/path/to/project"]
/ui-review window title="Exact title" [address="0x1234abcd"] [source="/absolute/path/to/project"]
/ui-review window address="0x1234abcd" [source="/absolute/path/to/project"]
/ui-review image path="/absolute/path/image.png"
```

Reject a bare URL, an unprefixed selector, relative image/source paths, unknown
keys, and malformed combinations. Return `BLOCKED: INVALID_TARGET` with the
accepted forms; do not route or navigate an invalid target.

The `web` form accepts repeated `url=` arguments and optional absolute
`source="/absolute/path/to/project"`. Review each URL independently: navigate,
bounded readiness wait, snapshot, screenshot, console, then findings grouped
by URL. Image paths must be absolute and are static evidence only. If `--fix`
is present, require explicit absolute `source=`; otherwise return
`BLOCKED: SOURCE_REQUIRED`. Capture baseline evidence before edits and fresh
evidence after the target's existing reload behavior. Without fresh readable
evidence return `BLOCKED: RELOAD_UNVERIFIED`, not a verified fix.

Only `/ui-review desktop` may list window titles. State that window titles may
contain sensitive information. For this discovery-only form, reproduce the
complete `ui_window_list` result verbatim in the final response; never say the
selectors were listed elsewhere. It is not a visual review: report
`DISCOVERY_COMPLETE`, or `BLOCKED: TARGET_NOT_FOUND` when no mapped windows
exist. Use the exact selector returned by `ui_window_list`. After
`ui_screenshot`, immediately read the `path` in its JSON result before
reporting findings. A screenshot request without readable image evidence is
`BLOCKED: EVIDENCE_UNAVAILABLE`, not `PARTIAL_REVIEW`. A `/ui-review window`
command with an exact selector authorizes only that selector's limited
visible-region capture; do not capture another window.

Use exactly one top-level result state: `VERIFIED_REVIEW` for readable evidence
within its declared scope, `PARTIAL_REVIEW` for usable but limited evidence, or
`BLOCKED: <reason>` when evidence cannot support review. A Desktop screenshot
is `VERIFIED_REVIEW` when its visible-region scope is readable; occluded content
is a scope limitation, not automatically partial evidence.

For Web, wait briefly for a Dioxus rebuild/loading overlay to disappear, then
capture a screenshot regardless of the wait result. Return
`BLOCKED: RUNTIME_STATE` only when screenshot evidence confirms a modal,
full-screen overlay, or other obstruction hides the primary content. A
non-blocking rebuild toast is a runtime note and does not prevent review.
Treat `ERR_BLOCKED_BY_CLIENT.Inspector` resource errors as an inspector
limitation, not a product finding; mark the visual evidence `PARTIAL_REVIEW`
instead.
