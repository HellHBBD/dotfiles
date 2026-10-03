# Backend Adapter Contract

Each adapter declares:

1. Identity: source documentation, installed version and tested source revision.
2. Status: candidate, approved, or verified for a specific operation/fixture.
3. Capability table: format and operation; supported, limited, unsupported, untested.
4. Preservation: demonstrated feature coverage and explicit loss/limitations.
5. Interface: actual tool schemas/help, units/index bases, inputs/output paths,
   overwrite semantics, atomicity, errors, warnings and findings.
6. Validation/rendering: available checks, image output and inspection coverage.
7. Runtime: dependencies, client permissions, path bounds, display requirements,
   local/cloud behavior, finite resource controls and lifecycle.
8. Fallbacks: eligible alternatives and hard stopping conditions.

Advertised capability is not tested capability. Approval is not test success.
Approval/configuration is client-specific and cannot be granted by this reference.
Never place credentials, package-manager launchers, automatic installation, or
unreviewed runtime activation in an adapter. Missing dependency checks apply only
to the selected operation; a working alternate backend must not be blocked by an
unrelated missing program.

Evidence records contain input fixture/version, requested change, output path,
backend/version, checks/findings, inspected pages, preservation differences and
result. A future backend is accepted only against workflow requirements, not by
reducing the requirements to its advertised feature set.
