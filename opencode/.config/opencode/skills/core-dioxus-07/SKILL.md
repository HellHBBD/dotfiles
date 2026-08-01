---
name: core-dioxus-07
description: Use when inspecting, modifying, debugging, or validating Dioxus 0.7 Rust applications, including RSX, components, signals, hooks, Cargo.toml, Dioxus.toml, Web, Desktop, Mobile, Fullstack, routing, and server functions.
---

# Dioxus 0.7

Use the Dioxus 0.7 documentation as the source of truth:
`https://dioxuslabs.com/learn/0.7/`. Do not apply APIs or behavior from 0.6
or earlier without checking the 0.7 migration guide.

## Scope And Boundaries

- Use for Dioxus 0.7 Rust projects and their `Cargo.toml`, `Cargo.lock`, and
  `Dioxus.toml` configuration.
- Do not use for unrelated Rust applications that do not depend on Dioxus.
- If the project uses a version other than 0.7, report the version mismatch and
  consult its matching documentation or migration guide before changing
  version-sensitive code.
- Do not install Rust targets, system packages, SDKs, the Dioxus CLI, templates,
  components, or third-party dependencies without explicit user approval.

## Forbidden Commands

- Never run, recommend, add to scripts, or include `dx serve` as a workflow
  example. This prohibition is unconditional, including when the user has
  approved command execution.

- Do not run `dx run` unless the user explicitly asks to launch the
  application. It starts an application or server even without hot reload.
- Do not use `dx new`, `dx init`, `dx components`, or `dx self-update` unless
  the user explicitly requests the associated creation, download, or update.

## Discover Before Editing

1. Read repository instructions and inspect the workspace before changing code.
2. Inspect `Cargo.toml`, `Cargo.lock`, and `Dioxus.toml` when present.
3. Identify the application package, binary, entry point, default features,
   platform features, workspace members, assets, and router/fullstack setup.
4. Confirm the installed CLI with `dx --version` when `dx` is available. Use
   `dx doctor` only to diagnose prerequisites; do not install anything it says
   is missing.
5. Select exact Dioxus 0.7 pages for the requested capability. Prefer the
   official page's `llms.txt` variant when available.

## Platform And Feature Rules

- Do not assume a project targets the web. Respect its existing default feature
  and `Dioxus.toml` configuration.
- Dioxus client platform features are normally `web`, `desktop`, and `mobile`;
  fullstack projects also use `server`. Verify the project's actual names
  before invoking commands.
- Validate each intended target separately. Do not use `--all-features` for a
  multi-platform app unless the project explicitly supports combining all
  features.
- Web targets compile to WASM. Keep native filesystem, socket, thread, and
  unsupported system dependencies out of the web dependency graph.
- Desktop applications render in a system WebView but execute Rust natively.
  Do not assume browser APIs are available; use platform-specific code only
  behind the appropriate feature or `cfg` guard.
- Treat Android and iOS builds as cross-compilation work. Do not start an
  emulator, boot a simulator, deploy to a device, sign artifacts, or install
  mobile toolchains unless explicitly requested.

## Components, RSX, And Reactivity

- Prefer `#[component]` functions returning `Element`; preserve local component
  structure and prop conventions.
- Props must produce correct render invalidation. Derive `Clone` and
  `PartialEq` when possible; never implement `PartialEq` so broadly that a UI
  change compares equal.
- Hooks must run in a stable order at the top level of a component or custom
  hook. Never call hooks conditionally, in loops, or in closures. Prefer early
  returns only after hooks have been declared.
- Use `use_signal` for component-owned mutable reactive state. Use context or
  global signals only when the ownership and lifetime need to cross component
  boundaries.
- Do not mutate signals while rendering. Use event handlers, `use_effect`, or
  a memo as appropriate.
- Model derived state with `use_memo`; model reactive asynchronous work with
  `use_resource`. Do not duplicate derived data into another signal without a
  concrete need.
- Do not hold a Signal `.read()` or `.write()` guard across an `await`. Clone
  or otherwise derive an owned value, release the guard, then await.
- Use stable, unique domain keys for dynamic RSX lists. Do not use an index as
  a key when list membership or ordering can change.
- Components can render repeatedly. Do not run non-deterministic work, network
  requests, state writes, or other side effects in a component body.

## UI, Assets, And Forms

- Keep RSX declarative and use HTML/CSS conventions supported by the selected
  renderer.
- Use `asset!()` for bundled local assets and retain the project's existing
  asset directory and stylesheet loading pattern.
- In Dioxus 0.7, browser form submission is allowed by default. Call
  `event.prevent_default()` only when the handler must prevent navigation or a
  native form submission.
- Preserve accessibility semantics, labels, keyboard interaction, focus
  behavior, and responsive behavior when modifying UI.

## Fullstack Rules

- A Dioxus fullstack application has separate client and server builds. Keep
  dependencies and code isolated by feature.
- Put server-only dependencies behind `optional = true` and enable them only in
  the server feature. Gate server-only imports and modules with
  `#[cfg(feature = "server")]` or the project's equivalent.
- Put browser-only dependencies behind the web feature and do not execute
  browser APIs on the server or desktop.
- Never place secrets, database credentials, private keys, or server-only
  implementation details in code compiled for a client target.
- Server functions must be async, return an appropriate `Result`, accept and
  return types compatible with their request/response serialization, validate
  untrusted input, and enforce authorization on the server.
- Use structured HTTP or `ServerFnError` handling when the client must respond
  differently to expected status codes. Do not expose internal error details to
  clients.

## Dioxus 0.7 Migration Checks

- `dioxus-lib` was removed; use the `dioxus` crate and `dioxus::prelude::*`.
- `#[server]` defaults to JSON encoding in 0.7. Verify external consumers
  before changing a server function protocol.
- Items such as `use_drop`, `Runtime`, `queue_effect`, and
  `provide_root_context` are no longer in the prelude and require explicit
  imports when still applicable.
- Review forms carefully because 0.7 changed their default submission behavior.

## Validation

Choose the narrowest commands that cover changed code. Do not start an app or
server for ordinary validation.

1. Format and inspect the diff:

    ```sh
    cargo fmt --check
    dx fmt --check --locked
    ```

2. When `dx` is available, validate the affected platform without launching it:

    ```sh
    dx check --web --locked
    dx check --desktop --locked
    dx check --server --locked
    ```

    Run only the platform commands the project supports and that are affected by
    the change. For fullstack work, validate client and server configurations
    separately when the project needs explicit target selection.

3. Use `cargo check`, `cargo clippy`, and `cargo test` with the project's
   package, feature, and target selection. Do not claim a target passed when
   only a different platform compiled.

4. Use `dx build --<platform> --locked` only when `dx check` cannot validate
   generated assets or bundling behavior required by the change. A build does
   not authorize launching, bundling, signing, or deployment.

5. Add focused tests for behavior changes when the project has an established
   test setup. Component output can be checked with SSR rendering; browser
   end-to-end tests require the project's existing runner and explicit approval
   if they start external processes.

6. Report every command run, its target/features, and any skipped validation
   with the reason.
