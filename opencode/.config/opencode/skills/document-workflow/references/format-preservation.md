# Format Preservation

Apply relevant source and target sections. Inspect actual container/content rather
than trusting an extension. Inventory important structures before editing; compare
them afterwards. Conversion can change representation, so identify permitted loss
before conversion. Never promise byte preservation merely because a backend says
it edits native formats.

## DOCX / DOTX

Preserve heading hierarchy, paragraph/run styles, numbering, tables, sections,
page setup, headers/footers, media/captions, equations, comments, tracked changes,
fields, bookmarks, links, content types, and package relationships when unrelated.
Inspect `[Content_Types].xml`, root/document relationships, and relevant parts.
Do not hand-edit XML for complex layout, revisions, fields, or compatibility
features. Require a backend with demonstrated preservation for those features.
Do not update fields or accept revisions implicitly. DOTX must remain a template.

## XLSX / XLSM / XLTX / CSV / TSV

Preserve formulas separately from cached values, cross-sheet references, defined
names, tables, charts/source ranges, styles, number/date formats, validation,
merged cells, conditional formatting, print settings, sheet names/order, external
references, and workbook relationships. Inspect workbook, worksheets, styles,
shared strings, content types, and relationships as relevant.
Do not refresh external data or replace formulas with displayed values implicitly.
CSV/TSV values stay literal unless intentional formulas are explicitly requested;
preserve delimiters, quoting, encoding, and significant string values.

For XLSM, never execute, inspect macro code, add, remove, or alter macros. Check
opaque macro-part preservation without interpreting it. If required preservation
cannot be demonstrated, return `BLOCKED: MACRO_PRESERVATION_UNVERIFIED`.
XLTX must remain a template; never assume a backend preserves VBA on save.

## PPTX / POTX

Preserve slide IDs/order, master/layout/theme relationships, media, speaker notes,
animations, transitions, shapes, links, and aspect ratio. Inspect content types,
presentation/slide relationships, layouts, masters, notes, and media references.
Use a capable native editor for nontrivial layouts rather than ad hoc XML edits.
POTX must remain a template. Do not flatten editable slides into page images unless
that output is explicitly requested.

## PDF

Distinguish text extraction, image extraction, OCR, page operations, conversion,
and native edits. Preserve page count/order, page boxes/rotation, text/OCR layers,
fonts, images, annotations, forms, and bookmarks as required. Do not assume a
render proves text accessibility, semantic tagging, or signature validity.
Recognize that edits may invalidate signatures. Scanned pages need a demonstrated
OCR capability for text reading; confidence and uncertain transcription must be
reported. Render and compare changed pages after native edits.

## Markdown / HTML

Preserve heading structure, lists, tables, code blocks, links, image references,
frontmatter, encoding, and unrelated markup. For HTML preserve document structure,
styles/assets and semantics; do not run scripts or retrieve external resources
without task-specific permission. Plain text editing is native to these formats;
conversion to Office still requires checking the target structure and layout.

## Sources

Use ECMA-376 for Office Open XML, ISO 32000 for PDF, the installed backend's
documentation, and the requested Markdown/HTML dialect. Do not import third-party
document prompts, templates, or helper implementations into this workflow.
