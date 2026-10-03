---
description: Run scoped document creation, editing, extraction, conversion, and verification through Document Agent.
agent: document-agent
subtask: true
---

Document task: $ARGUMENTS

Load `document-workflow`. Establish source/output paths, requested transformation,
preservation requirements, and verification scope. If arguments are empty, ask
for the document task instead of discovering unrelated files. Use fitness-first
routing and only approved available backends. The candidate adapter is not an
approved runtime. Follow the agent's path, tool, and resource permissions.
Deliver output paths with structural, preservation, and actual visual evidence;
mark unavailable required capabilities or unchecked gates explicitly.
