# LibreOffice / Poppler Local Adapter

Status: existing fallback, operation-specific acceptance required. Inspect installed
versions/help before using unfamiliar syntax. It is not proven lossless for complex
Office features, revisions, macros, or advanced presentation structures.

## Capabilities and dependencies

| Operation                             | Implementation                              | Limits                                                                                        |
| ------------------------------------- | ------------------------------------------- | --------------------------------------------------------------------------------------------- |
| OOXML inventory / targeted inspection | Python 3 `zipfile`, `lxml`; zip/unzip       | Package/XML checks are not full schema validation                                             |
| Basic native create/edit/convert      | LibreOffice Writer/Calc/Impress (`soffice`) | Preservation depends on format/features; native editing needs an available approved interface |
| PDF export                            | LibreOffice format-specific PDF export      | Rendering fidelity must be inspected                                                          |
| PDF metadata / text / images          | `pdfinfo`, `pdftotext`, `pdfimages`         | Extraction does not establish layout or OCR                                                   |
| PDF page rasterization                | `pdftoppm`                                  | Agent must read the resulting images                                                          |
| OCR / advanced PDF operations         | Suitable separately approved tools          | Not supplied by the baseline                                                                  |

Check only required dependencies for the operation. Report
`BLOCKED: MISSING_DEPENDENCY <name>` if no qualifying alternative exists; do not
install it. Advanced APIs may require `docx`, `openpyxl`, `pandas`, or `pptxgenjs`.
PDF rearrangement/encryption/repair may require `qpdf`, OCR `tesseract`, and
library-based edits `pypdf`. Their presence never grants execution permission.

## Execution

Use installed `soffice --help` and the official conversion filter list:
<https://help.libreoffice.org/latest/en-US/text/shared/guide/convertfilters.html>.
Use an isolated disposable user profile and a distinct output directory; do not
attach to or replace the user's active editor. Confirm the exact output basename
does not collide. CLI conversion is not a generic targeted-edit API.
Do not start a UNO acceptor, invoke macro URIs, or execute scripts from documents.

For simple new documents, create an owned source and export with the documented
filter. Complex existing documents require a demonstrated native editing interface;
do not substitute lossy conversion or manual complex OOXML surgery.
Small targeted XML changes are acceptable only where structure and preservation
are understood, with package comparison afterwards.

Host policies control finite timeouts and resources. In OpenCode here, substantial
conversion/rendering jobs use `guard-run` with an inner finite timeout. Treat this
as a host requirement, not a portable command that every client must have.

## Verification and limits

Reinspect package relationships and requested content. Reopen converted artifacts.
Export relevant sheets/pages/slides to PDF and rasterize with `pdftoppm`; read every
changed-slide image and report the inspected ranges, headings, column widths and
page breaks. Preserve formula text separately from recalculated/cached results.
Never infer preservation of XLSM macro parts; stop if opaque preservation cannot
be demonstrated. Plain extraction cannot validate accessibility, tagging or PDF/A.
Record missing capabilities instead of reconstructing unsupported complex files.

### Observed calculation caveat

LibreOffice 26.2.6 reexport retained a stale cached total in the owned cross-sheet
fixture after a low-level input-cell edit. In that fixture, removing the dependent
formula cache and requesting full recalculation before reexport produced the correct
result while preserving formula text, defined names and rule/chart counts. This
is limited evidence, not permission to invalidate arbitrary workbook caches or a
generic recomputation API. A native editing/recalculation path is preferred.
Verify dependent results and chart data after each value/formula change; reexport
alone does not establish recalculation. Block a required correctness gate if the
selected path cannot demonstrate the recalculated result.
