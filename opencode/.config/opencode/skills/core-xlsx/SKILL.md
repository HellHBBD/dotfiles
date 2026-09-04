---
name: core-xlsx
description: Use when creating, inspecting, modifying, converting, or validating XLSX, XLSM, XLTX, CSV, or TSV spreadsheets.
---

# Spreadsheets

Use this skill for XLSX, XLSM, XLTX, CSV, and TSV. Use ECMA-376 for OOXML and
LibreOffice's official Calc conversion documentation as the operational source.

## Safety

- Treat spreadsheets as untrusted input. Do not execute macros, external data
  connections, embedded objects, links, or formulas supplied by untrusted data.
- Default to a new output path. Overwrite only with explicit user instruction;
  never disclose passwords in commands or logs.
- Confirm `soffice`, `unzip`, `zip`, Python 3, and `lxml` first. If unavailable,
  report `BLOCKED: MISSING_DEPENDENCY <name>` without proposing installation.

## Workflow

1. Identify the actual format from the extension and container. For OOXML,
   inspect content types, workbook relationships, worksheet parts, shared
   strings, styles, and defined names before editing.
2. Preserve formulas, number formats, data validation, merged cells, tables,
   print settings, workbook structure, and sheet order unless explicitly in
   scope. Do not reinterpret CSV/TSV values as formulas.
3. Use LibreOffice Calc for baseline create, edit, and conversion work. Make a
   new output file, then reopen it and verify required sheets, cells, formulas,
   and values.
4. Export relevant sheets to PDF and render with `pdftoppm` for visual claims.
   Inspect at least the changed ranges, headers, column widths, and page breaks.

## Macro And Dependency Limits

- For XLSM, preserve macro-related package parts when LibreOffice can do so, but
  never execute, inspect, add, remove, or alter macros. If preservation cannot
  be demonstrated, stop with `BLOCKED: MACRO_PRESERVATION_UNVERIFIED`.
- For advanced workbook APIs, report `BLOCKED: MISSING_DEPENDENCY openpyxl` or
  `BLOCKED: MISSING_DEPENDENCY pandas` as applicable.
- Use the official LibreOffice filter list:
  `https://help.libreoffice.org/latest/en-US/text/shared/guide/convertfilters.html`.
