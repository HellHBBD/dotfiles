# GenOffice Candidate Adapter — Documentation Only

Status: **deferred runtime; not approved, installed, launched, registered, tested,
or selected as default by this adapter**. No version/commit has been approved.
This file does not authorize CLI execution or MCP activation.

Documentation inspected on 2026-10-03:

- <https://github.com/genspark-ai/genoffice/blob/main/packages/cli/README.md>
- <https://github.com/genspark-ai/genoffice/blob/main/README.md>

These moving references describe upstream claims, not a pinned production runtime.

## Candidate capability mapping

| Concept                             | Advertised MCP interface                                  | Acceptance status                         |
| ----------------------------------- | --------------------------------------------------------- | ----------------------------------------- |
| Inspect                             | `info`                                                    | Untested                                  |
| Structured DOCX read / edit / check | `docs_read`, `docs_apply`, `docs_check`                   | Untested                                  |
| Spreadsheet read / edit / check     | `sheet_read`, `sheet_apply`, `sheet_check`                | Untested                                  |
| Presentation read / edit / audit    | `slides_read`, `slides_apply`, `slides_audit`             | Untested                                  |
| PDF text read                       | `pdf_read`                                                | Untested; not proof of native PDF editing |
| Creation                            | `create_docx`, `create_xlsx`, `create_pptx`, `create_pdf` | Untested                                  |
| Render / convert                    | `render`, `slides_render`, `convert`                      | Untested                                  |
| Staged deck construction            | `deck_start`, `deck_page`, `deck_build`, `deck_replace`   | Untested                                  |

Do not use this table as an executable schema. After separate approval, verify the
pinned server's advertised tool names, parameter schemas, page/slide index bases,
units, output behavior, and resources. CLI and MCP supposedly share a registry;
verify this for the selected version. Compact schemas may require retrieving the
operation guide before constructing edits.

Upstream documents JSON findings/warnings in successful results; `docs check`
and `sheet check` can exit zero with findings. Inspect these fields explicitly.
Rendering/conversion can start a hidden app renderer; headless Linux may need a
display setup. GUI PDF editing is not proof of an equivalent MCP mutation tool.
OCR support is platform-specific and must be demonstrated on Linux.

## Future approval record

Before activation record source URL and resolved commit, package/runtime version,
complete production dependency closure and registry integrity, bundled renderer
revision, target paths, backup revision, fixed first-party launch command array,
security review, file roots, finite-job resource controls, and acceptance results.
Keep tools globally denied; grant only exact approved document tools to the scoped
Document Agent. Cloud `search`, `image`, and `media` require separate scope.
Do not use upstream installation scripts, automatic MCP installers, `latest`,
`npx`, package managers, or a PATH-dependent unpinned launcher at startup.

Test preservation against the workflow contract before promotion. Neither upstream
byte-preservation claims nor runtime approval establish fixture acceptance.
