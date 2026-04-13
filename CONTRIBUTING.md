# Contributing

The Parley protocol specification is the canonical normative description of the protocol. Changes are accepted via pull request, but the bar is high: substantive changes typically require updates to the reference implementation in `parley-crypto` and re-running the test vectors.

## What changes are accepted

- **Errata** (typos, broken links, citation fixes): submit a PR.
- **Clarifications** (wording improvements that do not change conformance): submit a PR with a short rationale.
- **Substantive changes** (new requirements, changed byte layouts, new conformance rules): open an issue first to discuss.

## Versioning

Stable versions are frozen at the version-numbered path (e.g. `v1/`). Breaking changes land in a new version directory; v1 itself does not mutate.

Within a stable version we issue patch releases (v1.0.1, v1.0.2) for editorial fixes that do not change conformance.

## Test vectors

Every pinned hex value in Appendix A must be reproducible from the reference test in `parley-crypto/crypto-e2e-tests/tests/spec_vectors.rs`. If your change affects any pinned value, you must update both the spec text and the test, and confirm the test is deterministic across two consecutive runs.

## Patent grant

By contributing, you agree that your contribution is licensed under the same terms as the rest of the document (CC BY 4.0) and that you make no patent claims against compliant implementations.
