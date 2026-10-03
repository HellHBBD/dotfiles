# Document Quality Gates

Apply only relevant gates, recording pass, fail, or unchecked with evidence.
Exit status, warnings, findings, text checks, package checks, and visual checks
are different evidence. A success envelope or exit code zero can contain defects.

## Content and preservation

Confirm the requested transformation, factual/numerical content, captions,
references, and absence of placeholders. Compare unrelated content and the
structures inventoried under [format preservation](format-preservation.md).
Ensure the input remains unchanged unless replacement was requested.

## Structural integrity

Reopen/parse the final artifact. For OOXML, check necessary parts, content types,
and internal relationship targets; distinguish external links from broken internal
targets without following them. XML well-formedness alone is not full schema
validation. Record backend checks and every unresolved finding.

- DOCX: sections, styles, tables, fields, references, headers/footers and media.
- XLSX: sheets, formulas, defined names, ranges, tables, charts and relationships.
- PPTX: slide order, layouts/masters, notes, themes and media.
- PDF: page count/order, geometry and required text/annotation/form structures.
- Markdown/HTML: syntax, requested semantics and asset/reference integrity.

## Spreadsheet integrity

Verify formula text, references/ranges, recalculated results when required,
number/date formats, chart source ranges, validation, sheet names/order and print
settings. Cached/displayed values alone do not prove formula integrity. Do not
execute untrusted imported formulas or external data connections to validate them.

## Visual integrity

For layout-sensitive work, render the final output and actually inspect the images.
Inspect every materially changed slide; for other formats state exact pages,
sheets/ranges and resolution. For a new substantial deck, inspect all slides.
Reject clipping/overflow, overlap, broken glyphs, missing/distorted media, unreadable
tables/text, unexpected blank pages, poor page breaks, and unintended spacing,
margins/alignment or aspect ratio changes. Repair then repeat relevant checks.
An automated geometry audit complements, not replaces, image inspection.

## Conversion integrity

Compare required text, tables, figures, equations, links, metadata, fonts and page
or slide boundaries. Record intended loss and unexpected loss separately. File
creation or successful conversion does not establish fidelity.

## Completion

All required applicable gates must pass for `VERIFIED` within the stated scope.
Use `PARTIAL` for deliverable work with declared unchecked gates, or `BLOCKED` when
a missing gate/capability prevents the requested deliverable. Never report visual
verification without reading the render. Structural and visual disagreements are
resolved using the corresponding evidence, not by dismissing either.
Do not claim PDF/A, accessibility, signature validity, standards conformance, or
print fidelity without the dedicated validation required for that claim.
