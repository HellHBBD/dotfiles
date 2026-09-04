---
name: core-docx
description: Use when creating, inspecting, modifying, converting, or validating DOCX or DOTX Word documents.
---

# DOCX And DOTX

Use this skill only for DOCX and DOTX work. Use ECMA-376 for Office Open XML
packaging and WordprocessingML, and LibreOffice's official help for conversion.

## Safety

- Treat documents as untrusted input. Do not execute macros, embedded objects,
  external links, or active content.
- Default to a new output path. Overwrite an input only on the user's explicit
  request. Never place passwords in commands or logs.
- Before work, confirm the source path, output path, requested changes, and
  that `soffice`, `unzip`, `zip`, Python 3, and `lxml` are available. Otherwise
  report `BLOCKED: MISSING_DEPENDENCY <name>`.

## Workflow

1. Inspect the package without changing it: list ZIP entries, check
   `[Content_Types].xml`, `_rels/.rels`, and `word/_rels/document.xml.rels`,
   then parse relevant XML with `lxml`.
2. Preserve the package's relationships, content types, styles, sections,
   headers/footers, numbering, and media unless the request explicitly changes
   them. Do not hand-edit XML for complex layout, tracked changes, fields, or
   compatibility features; use LibreOffice instead.
3. For a new simple document, create an owned source document and export to a
   distinct DOCX or DOTX output through LibreOffice. For an existing document,
   make the smallest requested change and save a distinct result.
4. Reinspect the output package and confirm required OOXML parts and targets
   resolve. Convert to PDF with LibreOffice and render PDF pages with
   `pdftoppm` before making any visual-quality claim.

## Limits

- Use LibreOffice conversion filters documented at
  `https://help.libreoffice.org/latest/en-US/text/shared/guide/convertfilters.html`.
- If a request needs DOCX-specific programmatic construction beyond the
  baseline tools, report `BLOCKED: MISSING_DEPENDENCY docx` rather than adding
  a library.
- Report package checks separately from rendered visual inspection. Neither
  proves the other.
