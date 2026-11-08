[← GlassPort overview](../README.md)

# GlassPort — validation and publication status

## Accepted baseline

The public portfolio describes the native AppKit/SwiftTerm shell, real local and system-SSH terminal execution, workspaces, tabs, focused companion pane, local launch directories, layout restoration, terminal appearance and app identity as accepted baseline functionality.

The persistence/restore slice was reviewed through native Mac build/test and physical product validation. Build success and actual interaction review are different evidence categories.

## Active development is not shipped functionality

Later work on terminal themes, command palette, workspace quick actions, SSH connection inspector, agent/keychain-related diagnostics, tunnels and skill-oriented integrations may appear in private draft or stacked branches. This showcase **does not treat a draft PR as accepted macOS product functionality**.

The dated state of the private repository can change more quickly than these public notes. A new claim should be checked against the latest accepted branch, relevant tests and real Mac interaction evidence before publication.

## Visual evidence still required

The repository does not yet include a privacy-reviewed, real GlassPort screenshot set. Three useful future captures are:

1. **Workspace navigation:** real AppKit workspace and tab arrangement.
2. **Local/SSH Session:** a working terminal with completely sanitized host and path details.
3. **Companion split:** one primary and one independent right-side terminal.

These are **capture requirements**, not produced assets. Only screenshots of an actually accepted build should be published. Synthetic mockups cannot be described as product captures.

## Public boundary

The implementation repo remains private. Do not publish real SSH aliases, hostnames, network details, credentials, complete shell history, sensitive paths, private diffs or internal log contents.

[Architecture decision →](native-workspace-architecture.md) · [Developer profile →](https://github.com/Charles-drZ)
