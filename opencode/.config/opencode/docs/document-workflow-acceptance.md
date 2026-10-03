# Document Workflow Acceptance

## Scope and evidence states

Target clients: OpenCode and local Linux Cherry Studio **2.1.4-1**. GenOffice runtime
is explicitly deferred. Do not install/launch/register GenOffice or invoke its CLI.
No academic domain skills or course rubric are implemented in this phase.

Track discovery, import, execution, preservation and verification separately.
Statuses: passed, failed, pending, blocked, deferred. A tool listing is configuration
evidence, not proof that an agent completed a document task. An exported ZIP is
not proof of Cherry Studio import or reference resolution.

## Fixtures

Use original generated fixtures, not third-party templates or personal documents.
`tools/document-fixtures.py` generates owned ODF sources with deliberate features;
convert them to native formats using the existing LibreOffice fallback. It is a
repository acceptance helper, not a bundled skill script or tool. Keep all generated
artifacts in an approved scratch directory outside the skill package.

| Native fixture          | Features and requested task                                                                                                       |
| ----------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| preservation.docx       | Heading style, table, header/footer, image/caption, explicit page break and comment; change only the target paragraph             |
| formulas.xlsx           | Formula/cross-sheet reference, named range, currency style, conditional rule and chart; change one input and verify recalculation |
| master-layout.pptx      | Master/layout relationships, theme part, image, styled text box and speaker note; change only target text                         |
| text.pdf                | Two pages with known text and geometry; extract with page locators and render both pages                                          |
| scanned.pdf             | Raster-only copy of a known page; detect no text layer, request OCR or report the missing capability                              |
| source.md / source.html | Headings/table/code/assets; targeted text change and optional conversion                                                          |

Advanced tracked changes, conditional-format evaluation, animations, macros, forms,
bookmarks, and accessibility are separate pending fixtures. Do not generalize the
baseline results to these features. Inventory converted fixtures before accepting
them; a failed source-to-native conversion cannot qualify a regression fixture.

## OpenCode

1. Restart to load the new skill, agent and command.
2. Confirm skill discovery and relative references; inspect the resolved agent.
   Check workflow allow, legacy skill deny in Document Agent, task/web/cloud deny,
   approval-gated file and shell access, and arbitrary unrelated MCP deny.
3. Test `/document` with an empty request: it should ask for a task, not scan files.
4. For each fixture, run the legacy workflow in one session and `/document` in
   another with identical requirements and distinct output directories. Review
   requested approval scopes. Record exact model/backend/version and output paths.
5. Compare requested changes, formula text/results, key structures/relationships,
   source retention and actual rendered output. Inspect all changed-slide images.
6. Check negative cases: hard preservation requirement unsupported by backend;
   missing OCR; text extraction misrepresented as native editing; active content
   treated as instructions; absent render; check findings despite successful exit.
7. Keep legacy skills enabled until the relevant shadow tests pass.

## Cherry Studio 2.1.4-1

Use the whole canonical folder via Settings → Skills → local-folder import (or
its exported ZIP). Verify these controls exist in the installed version; website
documentation is not version-specific proof. Enable the skill globally, then bind
it to a dedicated Agent through the available Agent/Skills editor. Do not import
the OpenCode agent/command/config as a portable skill.

1. Confirm name/version and complete relative references after import.
2. Ask the Agent to state the routing tie-breaker and the candidate adapter status
   using the actual references. Verify it can retrieve the backend/format files.
3. Configure only existing approved execution/file/image capabilities. A skill
   alone does not supply a shell or document tools. No GenOffice connection.
4. Run the same fixture tasks and negative cases, with new output directories.
5. Confirm rendered images are actually visible to the model and compare results.
6. Record screenshots/tool results and per-gate outcomes. Reimport updated exports
   from the canonical source; never maintain a divergent Cherry-only workflow.

If the installed client lacks an execution capability or the UI cannot be operated
by the current tools, report that gate blocked/pending and request user evidence.
Do not edit Cherry's internal database to simulate an import.

## Evidence record

For every task record client/version, workflow/version, backend/version, fixture,
request, source/output paths, approvals, structural findings, preservation changes,
formula checks, render paths/resolution, actually inspected page/slide scope,
limitations, overall state, and reviewer. Successful command exit is insufficient.

## Rollout status

Legacy retirement, real-agent shadow validation and Cherry UI acceptance remain
pending until evidence is recorded. GenOffice production acceptance is deferred by
explicit agreement. Configuration and backend smoke results are recorded separately
below after execution; neither substitutes for cross-client acceptance.

## Recorded evidence — 2026-10-03

Versions: OpenCode **1.18.33**; Cherry Studio package **2.1.4-1**;
LibreOffice package **26.2.6-2** (runtime 26.2.6.3); Poppler **26.08.0-1**;
qpdf **12.4.2-1**. Python `lxml` is available; `tesseract` is not on PATH.
No GenOffice runtime operation was performed.

### Configuration / packaging: passed within this scope

- Pure-mode skill discovery includes `document-workflow` and the retained legacy
  skills; all Markdown reference links resolve inside the package.
- Resolved `/document` invokes hidden subagent `document-agent`, `subtask: true`.
  Primary-agent switching and `@` autocomplete exclude this agent by configuration;
  live TUI behavior still requires a restarted-session check.
- Resolved Document Agent tools: read/glob/grep/bash/apply_patch available with
  approval; question/todowrite/skill available; task/webfetch/UI tools denied.
- Last-matching permission checks: new workflow allow, legacy workflow deny in
  Document Agent, input/edit/shell ask, secret reads deny, unrelated MCP deny,
  web/task deny and GenOffice invocation deny. Plan edit remains denied; Build and
  Plan can load the new workflow. These are resolved configuration results, not a
  live session's successful tool execution.
- Portable ZIP: `/tmp/opencode/document-workflow-1.0.0.zip`, containing the complete
  skill and its seven references. Package creation is not Cherry import acceptance.
- Prettier, fixture helper Ruff checks/format checks and Git whitespace checks
  passed when executed; rerun after any subsequent edit.

### Local backend smoke: tested, not agent shadow acceptance

Scratch evidence: `/tmp/opencode/document-acceptance/` (temporary, not a durable
backup). Original source generator: `tools/document-fixtures.py`. Initial XLSX
render exposed chart clipping across two pages; fixture chart geometry was corrected
and fresh native fixtures generated under `native-v2/`.

- DOCX: ZIP/XML and relationship checks; table, image, header/footer and comment
  parts present. Narrow paragraph edit changed only `word/document.xml`; unrelated
  parts stayed byte-identical. Reopened/exported successfully. Read both 72-DPI
  before/after page images: target changed, heading/table/image/caption and
  header/footer retained, deliberate second page retained. Comment package presence
  was checked; interactive comment behavior was not tested.
- XLSX: internal relationships, formula, defined name, chart and conditional rule
  present. Input changed from 10 to 15. First reexport kept stale total 30: **failed
  recalculation gate**. A separate owned-fixture experiment invalidated the single
  dependent cache and requested full recalculation; total became 35. Formula
  `SUM(Data!B2:B3)`, defined name and conditional-rule/chart counts matched baseline.
  Read both final 72-DPI sheet renders: input 15, total 35, chart fully within the
  first page with updated proportions; the second page contained Summary only.
  This limited experiment does not prove generic workbook recalculation or chart
  cache fidelity. Conditional rule presence is not verified visible evaluation.
- PPTX: master/layout/theme/notes/media relationships present. Narrow text edit
  changed only `ppt/slides/slide1.xml`; unrelated parts stayed byte-identical.
  Reopened/exported successfully; read the before/after slide at 72 DPI and confirmed
  target text and image placement. Custom master background/non-default theme
  fidelity is **unverified**; the baseline render was white, so no custom-background
  preservation claim is made.
- PDF: two known text pages extracted with page boundaries; rendered and read both
  pages. Raster-only fixture contains no extracted text, was rendered/read, and
  should report missing OCR for transcription. Both owned PDFs passed `qpdf --check`;
  that is not full standards/accessibility validation.

Native inventory checks: DOCX 15 package parts; XLSX 18; PPTX 20. No broken internal
relationship target was found. Native fixture conversion, PDF export and page
rasterization ran under `guard-run` with finite inner timeouts and isolated profiles.

### Pending and blocked gates

- Restarted `/document` session behavior and separate legacy/new shadow tasks:
  **pending**. No paid model-backed verification session was launched.
- Cherry folder/ZIP import, actual reference retrieval, Agent binding, execution
  and model-visible renders: **blocked on interactive user evidence**. The current
  tool session provides no Cherry UI interaction capability. Its installed version
  was verified through package ownership rather than the website.
- Advanced preservation fixtures and general recomputation: **pending**.
- Legacy retirement: **pending**; all legacy files/manifests and existing global
  permissions remain active. Document Agent itself excludes legacy workflows.
- GenOffice runtime/production acceptance: **deferred by agreement**.

### Next user-assisted test

Restart OpenCode, then run:

```text
/document Extract the text from /tmp/opencode/document-acceptance/sources/text.pdf with exact page locators. Do not modify the input. Report extraction coverage and distinguish it from visual verification.
```

Import the ZIP into Cherry Studio 2.1.4-1 and bind it to a dedicated Agent. First
ask it to read `references/tool-routing.md` and `references/backends/genoffice.md`
and report the routing priority and adapter status. Provide that response plus the
available document/file/image tools before attempting mutations. Use identical
fixture tasks across clients; record the results here before any legacy deny rollout.
