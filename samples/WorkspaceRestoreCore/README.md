# WorkspaceRestoreCore — standalone Swift engineering example

A **newly written public Swift sample** showing how a versioned layout description can be decoded, validated, and restored without confusing saved intent with live process state.

This is **not copied from, translated from, or executable against GlassPort's private implementation**. The demonstration deliberately uses an unrelated JSON format (`revision`, `spaces`, `canvas`, `tiles`) and generic surface roles rather than the application's private models or stored document schema.

The example illustrates:

- V1 metadata-only input upgraded in memory to a V2 representation.
- A malformed layout fragment discarded without losing its workspace ID or title.
- Validation of collection identity, selection, tile count, roles and focused tile.
- Explicit rejection of unsupported document versions instead of guessing.
- A restored data blueprint containing **no running processes, SSH authentication or PTY resources**.

Run from this public repository root with Swift 6 or newer:

```sh
swift test --package-path samples/WorkspaceRestoreCore
```

The package uses Foundation and Swift Testing only; no AppKit, SwiftTerm, filesystem writes, SSH endpoints or user profiles. The tests verify **this illustrative decoder and planner**, not the private application or physical macOS restore behavior. The sample has no integration with `CompanionLayoutCore`.

[GlassPort architecture](../../docs/native-workspace-architecture.md) · [Publication boundary](../../docs/public-source-boundary.md)
