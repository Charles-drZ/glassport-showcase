# GlassPort

**A native macOS workspace for local and remote development environments.**

GlassPort is a workspace-first developer tool: instead of organizing work around disconnected terminal windows and SSH connections, it groups local shells, remote systems, sessions, and project context around the workspace they belong to.

The first product goal is practical: replace my own Royal TSX local + SSH workflow with a native macOS tool that is simpler, more integrated, and designed around real daily development work.

## Product model

```text
Workspace
 ├─ Local Shell Port
 │    └─ Session
 ├─ SSH Port
 │    └─ Session
 └─ future workspace-specific actions
```

A Port describes an execution environment. A Session is a running terminal instance attached to a Port. A Port does **not** imply that a process is already running.

That distinction matters for lifecycle, persistence, lazy SSH startup, process cleanup, and future workspace composition.

## Validated engineering foundation

The current merged foundation includes:

- native macOS application shell using AppKit;
- SwiftTerm terminal integration;
- a real local `/bin/zsh -l` session over PTY;
- correct terminal resize and native keyboard/edit behavior;
- clean PTY/process shutdown;
- explicit Session lifecycle and restart behavior after natural shell exit;
- SSH as a first-class Port using the system `/usr/bin/ssh` client;
- lazy SSH Session creation on first selection;
- preservation of live Sessions while switching between Ports;
- concrete host-alias discovery from `~/.ssh/config`;
- system OpenSSH remaining authoritative for authentication, host keys, agent behavior, ProxyJump, and option resolution;
- durable local Workspace persistence with atomic writes and corruption-safe fallback;
- create, rename, switch, and delete Workspace flows;
- explicit separation between durable Workspace metadata and ephemeral runtime Session/PTY state.

The merged GLP-006 state passed `swift build`, `swift test`, and a native Xcode macOS build with 61 tests. Earlier terminal and SSH milestones also passed physical-product smoke testing, including a real interactive SSH connection.

A visual-shell refinement is currently in active review and is not presented here as merged product state.

## Engineering decisions

### Use the system SSH implementation

GlassPort does not reimplement SSH.

The app invokes `/usr/bin/ssh <alias>` through the same PTY/session architecture as the local shell. OpenSSH remains responsible for the security-sensitive parts it already handles well.

### Persist intent, not runtime machinery

Durable state currently stores Workspace identity and selection.

Live Sessions, PTYs, terminal scrollback, SSH credentials, resolved connection options, and process state remain runtime-only. Relaunch reconstructs a safe runtime from durable intent instead of attempting to serialize live process state.

### Lazy remote sessions

Discovered SSH Ports are visible without opening network connections. A real SSH Session is created only when the user explicitly selects that Port.

### Validate the actual product

Build success is necessary but not sufficient. Terminal focus, native commands, resize, shell exit/restart, real SSH interaction, process cleanup, and persistence behavior have been validated at the native app/runtime level.

## Product direction

The near-term product direction remains:

- workspace-first navigation;
- local shell and SSH as equal Port types;
- tabs and split panes;
- per-session working directory;
- Quick Actions;
- Command Palette;
- appropriate Keychain usage;
- native macOS interaction and visual polish.

GlassPort is intentionally **not** trying to become an RDP/VNC client, Kubernetes dashboard, Docker management suite, or AI chat application in its first product version.

## Technology

Swift · AppKit · SwiftTerm · PTY/process lifecycle · OpenSSH · Foundation persistence · XCTest · Xcode · native macOS

## What this project demonstrates

GlassPort combines product and systems concerns in one native application:

- developer-tool product design;
- process and terminal lifecycle;
- native macOS/AppKit work;
- trusted system-tool integration;
- local persistence contracts;
- failure and corruption handling;
- testable runtime boundaries;
- physical-product validation.

## Public boundary

The implementation repository remains private while the product evolves. This repository documents architecture, verified behavior, product decisions, and sanitized evidence without publishing private host configuration, credentials, or operational details.

## Related work

- [Developer profile](https://github.com/Charles-drZ)
- [Glassoft Agent Runtime](https://github.com/Charles-drZ/glassoft-agent-runtime-showcase)
- [NodeMedic](https://github.com/Charles-drZ/nodemedic-showcase)
- [Raspberry Home](https://github.com/Charles-drZ/raspberry-home-showcase)
