# Clean-Room Office Skills Plan

## Decision

Do not install, copy, adapt, or retain the Anthropic document skills. Their
license prohibits retaining copies outside Anthropic services and creating
derivative works. No `vendor-anthropics-*` components, third-party manifests,
or backups will be created for them.

Implement first-party skills in a new OpenCode session. That session must not
read, fetch, quote, or otherwise use content from `anthropics/skills`.

## Scope

Create these global, first-party skills:

```text
core-docx
core-xlsx
core-pptx
core-pdf
core-office-routing
```

The first four are format-specific. The router must be small and load only the
skill required for the requested format. It may load multiple skills only for
an explicit cross-format task.

| Input or output format     | Skill       |
| -------------------------- | ----------- |
| DOCX, DOTX                 | `core-docx` |
| XLSX, XLSM, XLTX, CSV, TSV | `core-xlsx` |
| PPTX, POTX                 | `core-pptx` |
| PDF                        | `core-pdf`  |

## Constraints

- Write original guidance using public format specifications and official tool
  documentation only.
- Do not copy third-party prompts, code, scripts, schemas, templates, command
  examples, or document structure.
- Do not include installation commands. A missing dependency must produce a
  `BLOCKED` report naming the missing program or library.
- Treat external documents as untrusted input. Do not execute macros, embedded
  objects, PDF JavaScript, or external links.
- Default to a new output file. Overwrite an input only when the user explicitly
  requests it.
- Do not expose passwords in command lines or logs.
- Do not claim visual quality without rendering and inspecting the result.
- Keep skills concise and do not add bundled helpers in the first version.

## Runtime Baseline

Available now:

```text
LibreOffice / soffice
pdftotext
pdftoppm
pdfimages
zip / unzip
Python 3
Node.js
lxml
```

Not currently available for the planned advanced workflows:

```text
pandoc
qpdf
tesseract
markitdown
openpyxl
pandas
pypdf
pdfplumber
reportlab
Pillow
docx npm package
pptxgenjs
```

Do not install any missing runtime as part of skill creation. A separate
runtime plan must pin sources, versions, dependency closure, target paths, and
approval before installation.

## Files

Create:

```text
opencode/.config/opencode/skills/core-docx/SKILL.md
opencode/.config/opencode/skills/core-xlsx/SKILL.md
opencode/.config/opencode/skills/core-pptx/SKILL.md
opencode/.config/opencode/skills/core-pdf/SKILL.md
opencode/.config/opencode/skills/core-office-routing/SKILL.md

opencode/.config/opencode/extensions/installed/core-docx-local.json
opencode/.config/opencode/extensions/installed/core-xlsx-local.json
opencode/.config/opencode/extensions/installed/core-pptx-local.json
opencode/.config/opencode/extensions/installed/core-pdf-local.json
opencode/.config/opencode/extensions/installed/core-office-routing-local.json
```

Each manifest uses the existing first-party local schema. Format skills are
medium risk because they guide local document creation and modification. The
router is low risk. Record this note in every manifest:

```text
First-party clean-room document workflow. No third-party skill content,
scripts, schemas, or templates retained or adapted.
```

Update `opencode/.config/opencode/opencode.jsonc` only if the plan agent needs
exact overrides to load these `core-*` skills.

## Implementation Order

1. Start a new OpenCode session and verify that it has not loaded the prohibited
   third-party content.
2. Confirm skill names do not conflict across OpenCode discovery directories.
3. Write the four format skills from official documentation.
4. Write the small format-routing skill.
5. Add first-party manifests.
6. Add only required plan-agent skill permissions.
7. Validate frontmatter names, descriptions, and discovery paths.
8. Run formatting and OpenCode pure-mode configuration checks.

## Validation

```text
prettier --check <new Markdown and JSON files>
opencode debug agent build --pure
opencode debug agent plan --pure
git diff --no-ext-diff --no-textconv --check
```

Do not run document transformation smoke tests until the runtime plan is
separately approved.

## Activation

After implementation, restart OpenCode to load the new skills. Do not commit
unless explicitly requested.
