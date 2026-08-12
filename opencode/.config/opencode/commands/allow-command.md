---
description: Review recurring shell commands and recommend safe Bash allow rules.
agent: allow-command-advisor
subtask: false
---

Review the current conversation's command history and this request:

$ARGUMENTS

Identify recurring read, diagnostic, test, and validation commands. Research
official documentation for their executable families and identify state-
changing or destructive exceptions.

Return recommended `ALLOW`, `ASK`, and `DENY` rules. Do not execute reviewed
commands or modify OpenCode configuration.
If no candidate command is visible in the current session, return `NOT_NEEDED`
without asking a question or inspecting external history.
