---
name: core-office-routing
description: Use when an Office-document request needs routing to the correct DOCX, spreadsheet, presentation, or PDF workflow skill.
---

# Office Format Routing

Route each document request to the smallest required format skill. This skill
does not itself transform files or replace format-specific safety checks.

## Routing

| Format                     | Load        |
| -------------------------- | ----------- |
| DOCX, DOTX                 | `core-docx` |
| XLSX, XLSM, XLTX, CSV, TSV | `core-xlsx` |
| PPTX, POTX                 | `core-pptx` |
| PDF                        | `core-pdf`  |

- Identify both source and requested output formats before loading a skill.
- Load one format skill for same-format work. Load multiple only for an explicit
  cross-format conversion, merge, or comparison task.
- If the format is missing, ambiguous, unsupported, or conflicts with file
  contents, ask for clarification rather than guessing.
- Keep each format skill's dependency checks, untrusted-input restrictions,
  output-path rules, and visual-verification requirements in force.
