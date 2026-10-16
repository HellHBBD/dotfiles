---
description: Check Arch Linux upgrade readiness, including a read-only desktop preflight before rebooting.
agent: arch-diagnostics
subtask: false
---

Interpret this Arch Linux health or upgrade request naturally, clarify only
material ambiguity, and follow the dedicated agent's read-only safety boundary:

$ARGUMENTS

Complete independent, non-privileged read-only checks first. Then present all
remaining independent privileged read-only commands together in one fenced
`bash` block for the user to run and return their complete outputs, errors, and
individual exit statuses in one reply. Split requests only when a later check
depends on an earlier result or that result may change the remaining checks.
Never execute privileged commands yourself. Assess the reboot gate only after
all required evidence is available; until then, use `NOT ASSESSED`.
