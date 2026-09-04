---
name: core-pdf
description: Use when creating, inspecting, extracting from, converting, or validating PDF documents.
---

# PDF

Use this skill for PDF input or output. Use ISO 32000 and the installed
Poppler and LibreOffice documentation as the source of truth.

## Safety

- Treat PDFs as untrusted input. Do not execute PDF JavaScript, launch embedded
  files, follow external links, or process embedded objects as executable data.
- Default to a distinct output file. Overwrite only by explicit request; never
  put passwords in command lines or logs.
- Confirm baseline tools before work: `pdftotext`, `pdftoppm`, `pdfimages`, and
  `soffice` when conversion is required. Report
  `BLOCKED: MISSING_DEPENDENCY <name>` for absent tools.

## Workflow

1. Identify whether the request is text extraction, image extraction, rendering,
   conversion, or a structural edit. Use `pdftotext` and `pdfimages` only for
   extraction; their output does not establish page layout.
2. Render relevant pages with `pdftoppm` and inspect them before reporting
   visual quality. State page range, resolution, and whether every changed page
   was examined.
3. For creation or conversion supported by baseline tools, produce a new PDF
   via LibreOffice and verify text and rendered pages. Preserve the original
   input unless explicitly told to overwrite it.
4. Keep structural, textual, and visual conclusions distinct. A successful
   render does not prove accessibility, semantic tagging, or print fidelity.

## Limits

- Report `BLOCKED: MISSING_DEPENDENCY qpdf` for page rearrangement, encryption,
  linearization, or structural repair requiring qpdf.
- Report `BLOCKED: MISSING_DEPENDENCY tesseract` for OCR and
  `BLOCKED: MISSING_DEPENDENCY pypdf` for library-based PDF editing.
- Do not claim PDF/A, accessibility, signature validity, or standards
  conformance without the required dedicated validator.
