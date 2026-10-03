# Document Workflow Migration

## Source and activation

Canonical source: `opencode/.config/opencode/skills/document-workflow/` in dotfiles.
The global skills directory resolves to that repository directory. The same whole
skill folder is exported to Cherry Studio; its imported copy is not a second
maintained source. Preserve relative references in folder/ZIP exports. A Cherry
Studio update requires reimport and verification, not an assumed live link.

`/document` invokes the hidden `document-agent` as a subtask without switching the
primary agent. It is excluded from primary-agent switching and `@` autocomplete.
The agent loads only the new workflow. Build and Plan may load the skill directly
(Plan remains read-only). Legacy skills stay
discoverable and enabled for other tasks until shadow acceptance. Do not combine
new and legacy workflows in one task. Restart OpenCode after configuration changes.

## Rule matrix

`migrated` means the requirement is present in the destination, not that a runtime
has proven it. `verified` requires fixture/runtime evidence. Line ranges refer to
the legacy files before this migration; those files are retained unchanged.

Destinations are relative to `skills/document-workflow/`:

- W: `SKILL.md`
- R: `references/tool-routing.md`
- F: `references/format-preservation.md`
- Q: `references/quality-gates.md`
- B: `references/backends/libreoffice-poppler.md`
- C: `references/backends/contract.md`

| Legacy              | Lines | Rule                                                                          | Destination | Status   |
| ------------------- | ----- | ----------------------------------------------------------------------------- | ----------- | -------- |
| core-office-routing | 8–9   | Router selects format requirements, not a transformation engine               | W, R        | migrated |
| core-office-routing | 13–18 | DOCX/DOTX, spreadsheet, PPTX/POTX and PDF coverage                            | W, F        | migrated |
| core-office-routing | 20–22 | Same-format minimum; source and target for explicit cross-format work         | W, R        | migrated |
| core-office-routing | 23–26 | Clarify unknown/conflicting formats; retain format checks                     | W, F, Q     | migrated |
| core-docx           | 8–9   | OOXML and official conversion documentation                                   | F, B        | migrated |
| core-docx           | 13–19 | Untrusted active content, new output, paths/passwords, dependencies           | W, B, C     | migrated |
| core-docx           | 23–25 | ZIP/content types/root and document relationships/XML inspection              | F, Q, B     | migrated |
| core-docx           | 26–29 | Relationships/styles/sections/headers/numbering/media; no complex XML surgery | F, B        | migrated |
| core-docx           | 30–32 | Owned simple source, native export, minimum edit and separate result          | W, B        | migrated |
| core-docx           | 33–35 | Reinspect targets, export PDF, inspect rasterized pages                       | Q, B        | migrated |
| core-docx           | 39–45 | Official filters, advanced dependency limits, structural/visual separation    | B, Q        | migrated |
| core-xlsx           | 8–9   | OOXML/official Calc documentation                                             | F, B        | migrated |
| core-xlsx           | 13–18 | Untrusted formulas/connections/active content, source/passwords/dependencies  | W, F, B     | migrated |
| core-xlsx           | 22–24 | Actual format, workbook/worksheet/shared-string/style/name inventory          | F           | migrated |
| core-xlsx           | 25–27 | Formulas/formats/validation/merges/tables/printing/order; literal CSV/TSV     | W, F, Q     | migrated |
| core-xlsx           | 28–30 | Calc baseline, new output, reopen and verify formulas and values              | B, Q        | migrated |
| core-xlsx           | 31–32 | Render changed ranges, headers, widths, page breaks                           | Q, B        | migrated |
| core-xlsx           | 36–38 | Opaque macro preservation, no execution/code inspection; block if unproven    | F, B        | migrated |
| core-xlsx           | 39–42 | Advanced dependency limits and official filters                               | B           | migrated |
| core-pptx           | 8–9   | OOXML packaging/PresentationML and official filters                           | F, B        | migrated |
| core-pptx           | 13–18 | Untrusted active content/media, new output/passwords/dependencies             | W, B        | migrated |
| core-pptx           | 22–24 | Container/slides/layout/master/theme/notes/media inventory                    | F           | migrated |
| core-pptx           | 25–27 | IDs/relationships/notes/animation/media preservation; native complex editing  | F, B        | migrated |
| core-pptx           | 28–30 | Requested slides only, separate result, verify layout/media targets           | W, F, Q     | migrated |
| core-pptx           | 31–32 | PDF export and inspect every changed-slide render                             | Q, B        | migrated |
| core-pptx           | 36–41 | Advanced dependency limits; XML/text not visual proof; official filters       | B, Q        | migrated |
| core-pdf            | 8–9   | ISO 32000 and installed backend documentation                                 | F, B        | migrated |
| core-pdf            | 13–19 | No active content, new output/passwords, operation-specific dependencies      | W, B        | migrated |
| core-pdf            | 23–25 | Classify extraction/render/conversion/edit; extraction not layout             | W, F, Q     | migrated |
| core-pdf            | 26–28 | Inspect images and report page coverage/resolution                            | Q           | migrated |
| core-pdf            | 29–33 | New PDF, verify text/images, source retention, separate conclusions           | W, Q, B     | migrated |
| core-pdf            | 37–40 | qpdf/OCR/library missing-dependency limits                                    | B, C        | migrated |
| core-pdf            | 41–42 | No unvalidated PDF/A/accessibility/signature/conformance claims               | Q           | migrated |

Backend dependencies are conditional on selecting that backend/operation; missing
LibreOffice must not block another eligible implementation. New requirements add
fitness-first routing, declared adapter status, source locators and unchecked-gate
reporting. None promotes an untested backend to production.

## Retirement gates

1. Migrate rules and review references/discovery/permissions.
2. Use identical fixtures/tasks in separate legacy/new sessions and separate output
   directories. Record backend/version and gate results; do not run both workflows
   together or mistake a backend-only smoke test for agent shadow validation.
3. Resolve regressions. Prove new coverage for the legacy operations being retired.
4. Only then add exact legacy skill denies to relevant agents. Keep files and
   manifests; test resolved permissions and skill discovery after restart.
5. Observe real tasks. Removal requires a later explicit request and backup.

Current retirement state: **pending shadow acceptance; no legacy skill disabled**.
Recovery before retirement is simply selecting the existing core skill in a
separate task. After retirement, restore only the exact permission changes and
restart; never overwrite unrelated config or user files.
