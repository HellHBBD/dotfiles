# Domain Integration Contract

The reading tutor and academic reviewer are future consumers, not implemented or
refactored by this package. Domain reasoning and evaluation criteria stay outside
the document workflow. A reference link does not imply another skill exists.

## Request

Supply source path/format, operation, exact sections/pages/sheets/slides/ranges,
required preservation, output path for mutations, requested render scope and
acceptance criteria. For ambiguous edits, supply the proposed replacement or ask
the user to resolve intent before changing the artifact.

## Response

Return structured content or output paths, source locators, backend/version,
extraction coverage/truncation, OCR use and uncertainties, structural findings,
render paths and inspected scope, preservation evidence and unresolved limitations.
Never invent page numbers, citations, OCR certainty, or verification results.

## Boundaries

- `paper-reading-tutor`: read/extract requests only by default. Explain the paper
  from returned evidence; it is not a document editor.
- `academic-reviewer`: request content and renders, evaluate using actual supplied
  course/project rubrics, and propose explicit changes. Evaluation does not itself
  authorize applying edits. Do not infer a professor's preferences.
- `document-workflow`: perform authorized file operations and report evidence;
  do not set academic scores or fabricate domain criteria.

Reviewer feedback may enter a read → proposed changes → authorized edit → render
→ review loop. Rubrics remain user/project references; no default course rubric
is bundled here.
