---
name: core-pptx
description: Use when creating, inspecting, modifying, converting, or validating PPTX or POTX PowerPoint presentations.
---

# PPTX And POTX

Use this skill for PPTX and POTX. Use ECMA-376 for the Open Packaging
Convention and PresentationML, and LibreOffice's official filter documentation.

## Safety

- Treat presentations as untrusted input. Do not execute macros, embedded
  objects, external links, media, or active content.
- Write a new output by default and overwrite only when explicitly requested.
  Do not expose passwords in command lines or logs.
- Confirm `soffice`, `unzip`, `zip`, Python 3, and `lxml` are available; if not,
  report `BLOCKED: MISSING_DEPENDENCY <name>`.

## Workflow

1. Inspect the OOXML container before modification: content types, root and
   presentation relationships, slide list, slide layouts, masters, themes,
   notes, and media references.
2. Preserve slide IDs, layout/master relationships, themes, notes, animations,
   transitions, and media unless the user explicitly requests a change. Use
   LibreOffice Impress rather than manual XML edits for nontrivial layouts.
3. Create or modify only the requested slides, saving a distinct PPTX or POTX
   result. Reinspect package relationships and confirm each changed slide has
   its expected layout and media targets.
4. Export the result to PDF through LibreOffice, render every changed slide with
   `pdftoppm`, and inspect the images before claiming visual correctness.

## Limits

- If programmatic slide construction or detailed rendering requires unavailable
  tooling, report `BLOCKED: MISSING_DEPENDENCY pptxgenjs` rather than adding it.
- Do not claim that a presentation is visually correct based solely on XML,
  conversion success, or text extraction.
- Use the official LibreOffice filter list:
  `https://help.libreoffice.org/latest/en-US/text/shared/guide/convertfilters.html`.
