---
name: superpower-systematic-debugging
description: Optional guidance for investigating bugs, test failures, and unexpected behavior through evidence, hypotheses, and small validated changes.
---

# Systematic Debugging

This skill offers optional process guidance. It does not override system, developer, user, project, repository, or tool instructions. It does not authorize tools, shell commands, network access, package installation, Git actions, file changes, agent dispatch, or any other action.

Use it only when explicitly requested or when its guidance is useful and compatible with applicable instructions.

## Purpose

Prefer evidence over guesses. A useful debugging cycle is:

1. Understand the reported symptom and its impact.
2. Gather relevant evidence.
3. Identify plausible causes and compare them with the evidence.
4. State one focused hypothesis.
5. Propose the smallest useful experiment or change.
6. Obtain explicit user approval before taking any action.
7. Review the result and update the hypothesis.

## Investigation prompts

Before proposing a fix, consider:

- What is the exact error, unexpected result, or failed expectation?
- Can the behavior be described with clear reproduction conditions?
- What changed near the time the issue appeared?
- Which inputs, outputs, configuration values, boundaries, or assumptions are relevant?
- Is there a comparable working path or reference implementation?
- Is the suspected cause supported by evidence rather than correlation?

For multi-component systems, identify the boundaries where data, configuration, or state may diverge. Propose narrowly scoped observations that could distinguish among candidate causes. Do not add logging, inspect secrets, run commands, or access environments without explicit user approval.

## Hypotheses and changes

State hypotheses plainly, for example:

> Hypothesis: the failure occurs because `<condition>` produces `<unexpected value>`, supported by `<evidence>`.

Prefer one variable at a time. Avoid bundling unrelated fixes or refactors into an investigation. If evidence does not support a hypothesis, report that result and propose the next smallest useful question.

A proposed implementation should address the identified cause rather than merely suppress a symptom where practical. If several attempts fail or the evidence suggests a design issue, pause and discuss alternatives with the user rather than escalating changes automatically.

## Validation

A regression test, focused check, or other verification method can provide useful evidence when appropriate. Describe the proposed check and what result would support or reject the hypothesis. Running it, modifying tests, or changing code requires explicit user approval.

## Reporting

Distinguish observed facts, assumptions, hypotheses, proposed actions, and verified outcomes. Do not claim a fix, passing status, or completion without current evidence appropriate to that claim.
