[← GlassPort overview](../README.md)

# GlassPort — validation and publication status

## Accepted baseline

The public portfolio describes the native AppKit/SwiftTerm shell, real local and system-SSH terminal execution, workspaces, tabs, focused companion pane, local launch directories, layout restoration, terminal appearance and app identity as accepted baseline functionality.

The persistence/restore slice was reviewed through native Mac build/test and physical product validation. Build success and actual interaction review are different evidence categories.

## Active development is not shipped functionality

Later work on terminal themes, command palette, workspace quick actions, SSH connection inspector, agent/keychain-related diagnostics, tunnels and skill-oriented integrations may appear in private draft or stacked branches. This showcase **does not treat a draft PR as accepted macOS product functionality**.

The dated state of the private repository can change more quickly than these public notes. A new claim should be checked against the latest accepted branch, relevant tests and real Mac interaction evidence before publication.

## Published macOS product screenshots

The [public README](../README.md) includes three real macOS application screenshots:

1. **Workspace overview:** sidebar, tabs, Local Shell, and visible Port list.
2. **SSH terminal:** an interactive Raspberry Pi remote session.
3. **Companion split:** two independent Local Shell sessions attached to the same Port.

The current split action creates a new Session for the current Port. It does not demonstrate a Local Shell + SSH mixed-Port split. The screenshots show visible interaction, not full release or QA acceptance. No generated mockups are used as application captures.

## Independently runnable Swift example

[CompanionLayoutCore](../samples/CompanionLayoutCore/) is a new Swift Package demonstrating general companion-pane state transitions and distinguishing a saved layout description from ephemeral runtime identity. It includes its own Swift Testing suite and GitHub-hosted macOS validation workflow. **Its tests do not replace or establish the private GlassPort's XCTest, AppKit or physical-device validation.** The package does not create terminals, connect to SSH or handle user data.

The [public source boundary](public-source-boundary.md) distinguishes this independently authored sample from the application's private implementation.

## Second public Swift example

[WorkspaceRestoreCore](../samples/WorkspaceRestoreCore/) independently illustrates safe decoding, in-memory revision upgrade, invalid-layout isolation and saved-intent boundaries. Its `Codable` fields are **not** GlassPort's production storage schema, and its Swift Testing suite does not establish production restore correctness.

## Public boundary

The implementation repo remains private. Do not publish real SSH aliases, hostnames, network details, credentials, complete shell history, sensitive paths, private diffs or internal log contents.

[Architecture decision →](native-workspace-architecture.md) · [Developer profile →](https://github.com/Charles-drZ)
