# Fitness-First Tool Routing

1. List fidelity and preservation requirements for this operation and format.
2. List required capabilities: inspect, structured read, create, targeted modify,
   check, render, audit, convert, OCR, or extraction. These are conceptual labels.
3. Exclude backends lacking required fidelity, capabilities, or allowed paths.
4. Among qualifying implementations prefer structured native/MCP tools, then a
   document CLI, a specialized library, and finally suitable low-level tools.
5. Use more than one backend only for a justified missing capability, checking
   intermediate fidelity and keeping all artifacts within the approved scope.

A native tool preserving revisions beats an MCP tool that discards them. A
filesystem edit is appropriate for a narrow Markdown change. Text extraction
is appropriate for reading a PDF, but does not establish native-editing fidelity.

Read [the backend contract](backends/contract.md) and the selected adapter.
[LibreOffice/Poppler](backends/libreoffice-poppler.md) documents the existing local
fallback. [The candidate adapter](backends/genoffice.md) is documentation only,
not an approved runtime or the default backend.

Inspect currently advertised schemas or installed help. Verify page/slide index
bases, units, defaults, overwrite behavior, output paths, and check-result semantics.
Do not assume a GUI feature has a CLI/MCP equivalent. Never execute an unavailable
or unapproved backend merely to discover its tools.

Selection does not authorize external access, cloud operations, installation, or
new permissions. Client-specific scope and resource controls remain binding.
Return a named missing capability if no eligible backend meets a hard requirement;
ask before accepting a fidelity-reducing fallback.
