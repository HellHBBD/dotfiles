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
        "cargo check*": allow
        "cargo test*": allow
        "cargo clippy*": allow
        "cargo tree*": allow
        "cargo nextest run*": allow
        "dx check --web --locked": allow
        "dx check --desktop --locked": allow
        "dx check --server --locked": allow
        pytest: allow
        "pytest *": allow
        "python -m pytest": allow
        "python -m pytest *": allow
        "python3 -m pytest": allow
        "python3 -m pytest *": allow
        "python -m unittest": allow
        "python -m unittest *": allow
        "python3 -m unittest": allow
        "python3 -m unittest *": allow
        "uv run pytest": allow
        "uv run pytest *": allow
        "go test *": allow
        "go vet *": allow
        "npm test*": allow
        "npm run test*": allow
        "npm run check*": allow
        "npm run lint*": allow
        "npm run typecheck*": allow
        "pnpm test*": allow
        "pnpm run test*": allow
        "pnpm run check*": allow
        "pnpm run lint*": allow
        "pnpm run typecheck*": allow
        "pnpm exec tsc --noEmit": allow
        "bun test*": allow
        "bun run test*": allow
        "bun run check*": allow
        "bun run lint*": allow
        "bun run typecheck*": allow
        "tsc --noEmit*": allow
        mypy: allow
        "mypy *": allow
        pyright: allow
        "pyright *": allow
        eslint: allow
        "eslint *": allow
        "biome check*": allow
        "biome lint*": allow
        vitest: allow
        "vitest *": allow
        jest: allow
        "jest *": allow
        "cargo *--manifest-path*": ask
        "cargo *--config*": ask
        "cargo *--target-dir*": ask
        "cargo * -Z*": ask
        "npm *--prefix*": ask
        "pnpm *--dir*": ask
        "pnpm * -C*": ask
        "bun *--cwd*": ask
        "uv *--project*": ask
        "uv *--directory*": ask
        "pytest *--rootdir*": ask
        "cargo clippy *--fix*": ask
        "eslint *--fix*": ask
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
