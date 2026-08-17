---
description: Evaluate current evidence for completion, test, build, and verification claims.
mode: subagent
hidden: true
model: openai/gpt-5.6-luna
options:
    reasoningEffort: medium
permission:
    edit: deny
    bash:
        "cargo metadata --no-deps --locked": allow
        "cargo fmt --check": allow
        "cargo check": allow
        "cargo check --locked": allow
        "cargo test": allow
        "cargo test --locked": allow
        "cargo clippy": allow
        "cargo clippy --locked": allow
        "pnpm test": allow
        "pnpm run lint": allow
        "pnpm run typecheck": allow
        "pnpm exec tsc --noEmit": allow
        "git add*": deny
        "git -C * add*": deny
        "git commit*": deny
        "git -C * commit*": deny
        "git merge*": deny
        "git -C * merge*": deny
        "git rebase*": deny
        "git -C * rebase*": deny
        "git reset*": deny
        "git -C * reset*": deny
        "git clean*": deny
        "git -C * clean*": deny
        "git push*": deny
        "git -C * push*": deny
    task: deny
---

Distinguish verified facts from assumptions. Propose focused verification and
report its scope and limitations. Do not modify files or make completion claims
without current evidence.
