---
description: Inspect, install, update, remove, and audit third-party OpenCode extensions
agent: extension-manager
subtask: true
---

Manage third-party OpenCode extensions according to this request:

$ARGUMENTS

Supported syntax:

- help
- inspect <git-url> [--ref <git-ref>]
- install <git-url> [--ref <git-ref>] [--scope project|global] [--only <component-selector>]
- install <source-id> [--scope project|global] [--only <component-selector>]
- update <installation-id>
- remove <installation-id>
- list [--scope project|global|all]
- show <installation-id>
- doctor [--scope project|global|all]

Component selectors:

- skill:<relative-path>
- command:<relative-path>
- plugin:<relative-path>
- npm-plugin:<module>

Multiple selectors are comma-separated.

Defaults:

- With no action, show help.
- With no scope, use project scope.
- With no selector, inspect and present available components only; never install all components.
- A repository URL is not approval to activate its contents.
- Never skip inspection or explicit approval.
