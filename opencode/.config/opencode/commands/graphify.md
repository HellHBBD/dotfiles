---
description: Build, refresh, or query a local code knowledge graph using the restricted Graphify skill.
agent: build
subtask: false
---

Before any Graphify execution, load the installed `graphify` skill with the
`skill` tool for this invocation. Do not rely on Graphify instructions
previously loaded in this conversation.

Follow that skill for this explicit request:

$ARGUMENTS

For an active-workspace build or refresh, never run `graphify update`. Subject
to the skill's prechecks and postchecks, use only:

```bash
graphify extract <workspace> --code-only --no-cluster
```

Queries remain supported only as allowed by the loaded skill.

Do not install or upgrade software. Do not access networks, credentials, environment variables, hooks, plugins, MCP, watchers, databases, or non-code corpus files.
