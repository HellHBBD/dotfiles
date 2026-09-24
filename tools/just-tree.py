#!/usr/bin/env python3
"""Render the static dependency graph from this repository's Justfile."""

import json
import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
JUST_CALL = re.compile(
    r"^\s*@?just\s+([A-Za-z0-9][A-Za-z0-9_-]*)(?:\s+([A-Za-z0-9_-]+))?\s*$"
)
HELPERS = {"default", "tree"}


def recipe_label(name: str, arguments: list[str] | None = None) -> str:
    return " ".join([name, *(arguments or [])])


def body_line(line: list[object]) -> str:
    return "".join(
        part if isinstance(part, str) else "{{ expression }}" for part in line
    )


def load_recipes() -> dict[str, dict[str, object]]:
    result = subprocess.run(
        ["just", "--dump", "--dump-format", "json"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    if result.returncode:
        raise RuntimeError(result.stderr.strip() or "just could not dump the Justfile")

    return json.loads(result.stdout)["recipes"]


def children(recipe: dict[str, object]) -> list[tuple[str, list[str], str]]:
    result = [
        (dependency["recipe"], dependency["arguments"], "dependency")
        for dependency in recipe["dependencies"]
    ]
    for line in recipe["body"]:
        match = JUST_CALL.fullmatch(body_line(line))
        if match:
            result.append(
                (match.group(1), [match.group(2)] if match.group(2) else [], "call")
            )
    return result


def render(
    recipes: dict[str, dict[str, object]],
    name: str,
    arguments: list[str],
    prefix: str,
    is_last: bool,
    ancestors: set[tuple[str, tuple[str, ...]]],
    edge: str | None = None,
) -> None:
    key = (name, tuple(arguments))
    connector = "└── " if is_last else "├── "
    suffix = " [本體呼叫]" if edge == "call" else ""
    print(f"{prefix}{connector}{recipe_label(name, arguments)}{suffix}")

    if key in ancestors:
        print(f"{prefix}{'    ' if is_last else '│   '}└── ↩ 循環依賴")
        return

    recipe = recipes.get(name)
    if recipe is None:
        print(f"{prefix}{'    ' if is_last else '│   '}└── ? 未找到 target")
        return

    entries = children(recipe)
    child_prefix = prefix + ("    " if is_last else "│   ")
    next_ancestors = ancestors | {key}
    for index, (child, child_arguments, child_edge) in enumerate(entries):
        render(
            recipes,
            child,
            child_arguments,
            child_prefix,
            index == len(entries) - 1,
            next_ancestors,
            child_edge,
        )


def roots(recipes: dict[str, dict[str, object]]) -> list[str]:
    referenced = {
        child for recipe in recipes.values() for child, _, _ in children(recipe)
    }
    return sorted(
        name for name in recipes if name not in referenced and name not in HELPERS
    )


def main() -> int:
    try:
        recipes = load_recipes()
    except (RuntimeError, json.JSONDecodeError) as error:
        print(f"無法讀取 Justfile：{error}", file=sys.stderr)
        return 1

    targets = [target for target in sys.argv[1:] if target]
    if len(targets) > 1:
        print("用法：just tree [target]", file=sys.stderr)
        return 2
    if targets:
        if targets[0] not in recipes:
            print(f"找不到 target：{targets[0]}", file=sys.stderr)
            return 2
        print(targets[0])
        entries = children(recipes[targets[0]])
        for index, (child, arguments, edge) in enumerate(entries):
            render(
                recipes,
                child,
                arguments,
                "",
                index == len(entries) - 1,
                {(targets[0], ())},
                edge,
            )
    else:
        print("Just target 依賴樹")
        for name in roots(recipes):
            print()
            print(name)
            entries = children(recipes[name])
            for index, (child, arguments, edge) in enumerate(entries):
                render(
                    recipes,
                    child,
                    arguments,
                    "",
                    index == len(entries) - 1,
                    {(name, ())},
                    edge,
                )

    print("\n圖例：一般節點是前置依賴；[本體呼叫] 代表 recipe 執行中遞迴呼叫 just。")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
