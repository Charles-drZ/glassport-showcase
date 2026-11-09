# CompanionLayoutCore — standalone Swift engineering example

This **newly authored demonstration** explores a small, testable state-management problem inspired by the public [GlassPort companion split](../../README.md). Its types and tests are **not** copied or adapted from the private GlassPort implementation.

The sample is deliberately separated from AppKit, SwiftTerm, PTYs, OpenSSH, filesystem persistence and actual process management.

## What the example demonstrates

A tab has a primary pane and at most one companion. Splitting a pane creates a *distinct runtime identity* while preserving its target. Focus changes and pane closures are explicit, and an invalid operation leaves state unchanged.

A simplified saved-intent projection retains selected pane and target identity while omitting ephemeral runtime tokens. It is an illustrative data representation, **not** GlassPort's private persistence schema.

The tests cover creating a companion, independent runtime identity, rejecting a third pane and duplicate identities, selecting and closing panes, final-pane closure, remote-target consistency, inter-tab isolation, and saving only layout intent.

## Try it

Requires Swift 6.0 or newer. From the showcase repository root:

```sh
swift test --package-path samples/CompanionLayoutCore
```

This is a dependency-free Swift Package using Swift Testing. It never creates a shell, an SSH connection or a process, and contains no real account names, aliases or credentials.

## Evidence boundaries

The public tests establish only the behavior of **this example**. They do not reproduce GlassPort's private XCTest suite, certify process shutdown, establish AppKit focus behavior or validate physical macOS interaction.

No license or permission to reuse the private application is implied by this sample.

[Read the macOS architecture case study](../../docs/native-workspace-architecture.md) · [Back to showcase](../../README.md)
