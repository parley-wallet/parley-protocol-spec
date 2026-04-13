# Parley Protocol Specification

This repository hosts the canonical specification for the **Parley privacy-preserving age verification protocol**.

- **Canonical URL**: <https://spec.parleywallet.app/v1/protocol.html>
- **Latest stable**: [v1.0.0](v1/protocol.md)
- **Reference test vectors**: [v1/protocol.md Appendix A](v1/protocol.md), reproducible via [`parley-crypto/crypto-e2e-tests/tests/spec_vectors.rs`](https://github.com/parley-wallet/parley-crypto/blob/main/crypto-e2e-tests/tests/spec_vectors.rs)
- **Reference implementation**: [parley-wallet/parley-crypto](https://github.com/parley-wallet/parley-crypto)

## What this is

A specification of the cryptographic primitives, wire formats, and protocol flows that any implementation must follow to be interoperable with the Parley network. Written for engineers building wallets, issuers, verifiers, or independent re-implementations.

This is not a marketing document or a product overview. Those live at <https://parleywallet.app>.

## Versioning

Versioned freezes live under `v{MAJOR}/`. v1 is stable; breaking changes will land as a v2 directory rather than mutating v1.

## Patent

Australian Provisional Patent Application No. 2026901546, filed 26 February 2026. Royalty-free patent grant for compliant implementations with defensive termination — full statement in [v1/protocol.md §Copyright and Licence Notice](v1/protocol.md).

## Document licence

This specification is published under [CC BY 4.0](LICENSE).

## Reporting issues

Errata and questions: <https://github.com/parley-wallet/parley-protocol-spec/issues>.

## Conformance

An implementation may claim "Parley v1.0 Compliant" if it satisfies every MUST in [v1/protocol.md §Conformance](v1/protocol.md). The reference test vectors in Appendix A are normative — implementations MUST reproduce every pinned hex value bit-for-bit.
