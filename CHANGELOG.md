# Changelog

All notable changes to the Parley protocol specification.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v1.0.0] — 2026-04-13

Initial stable release.

- Three-party protocol (Issuer, Wallet, Verifier) with bidirectional age threshold proofs
- Cryptographic primitives: Groth16 over BLS12-381, Pedersen commitments on Jubjub, RedJubjub signatures, Ed25519 attestations, Blake2s-256 throughout
- 192-byte zero knowledge proofs reveal only a binary age bracket
- Single circuit handles both `Over` and `Under` directions via a public direction bit
- Full wire format specification with pinned byte layouts
- Conformance section defining what an implementation must satisfy
- Normative test vectors in Appendix A, reproducible via `parley-crypto/crypto-e2e-tests/tests/spec_vectors.rs`
