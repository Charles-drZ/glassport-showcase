# GlassPort

**A native macOS workspace for local and remote development environments.**

**Focus:** Swift · AppKit · native macOS · terminal/PTY lifecycle · OpenSSH · persistence · developer tools

GlassPort is a workspace-first developer tool. Instead of organizing work around disconnected terminal windows and SSH connections, it groups local shells, remote systems, tabs, live terminal sessions and project context around the workspace they belong to.

The practical product goal is still the same: replace a fragmented Royal TSX + Terminal workflow with a native macOS tool that is simpler, more coherent, and designed around real daily development work.

## Product model

```text
Workspace
 ├─ Local Shell Port
 │    └─ Session
 ├─ SSH Port
 │    └─ Session
 └─ tabs / optional companion pane
```

A **Port** describes an execution environment. A **Session** is a running terminal process attached to a Port. Durable workspace intent stays separate from ephemeral PTYs, PIDs and live process state.

That distinction drives restore behavior, lazy SSH startup, process cleanup, persistence and future workspace composition.

## Current accepted product state

The merged and physically accepted product now includes:

- a native AppKit application shell;
- SwiftTerm terminal rendering;
- real local `/bin/zsh -l` sessions over PTY;
- system `/usr/bin/ssh` as the SSH implementation;
- concrete SSH alias discovery from the user's OpenSSH config;
- native terminal tabs;
- explicit Session end/restart lifecycle;
- Workspace create / rename / switch / delete;
- durable Workspace identity and selection;
- **one optional right-side companion terminal pane** with independent live Session/PTY;
- native draggable split divider;
- per-session Local Shell launch working directory;
- **Restart in Folder…** without injecting `cd` into a running shell;
- working-directory inheritance for new Local sessions and the companion pane;
- durable restoration of tab order, active tab, pane identity, Port intent and Local launch directory;
- safe cleanup when a previously saved SSH alias no longer exists;
- a restrained Local Shell terminal environment with `TERM=xterm-256color`, truecolor capability and user-setting/NO_COLOR preservation;
- Light/Dark-safe terminal selection colors;
- a dedicated GlassPort Dock icon and in-product portal identity.

The important part is not only that these features compile: the GLP-010 through GLP-014 product slices were accepted after native macOS build/test and physical-product review.

## Companion pane, not a generic tiling terminal

GlassPort deliberately rejected an unrestricted multi-pane grid.

The accepted split model is:

- one primary terminal;
- one optional right-side companion;
- both Sessions remain independently live;
- the native divider is draggable;
- closing the companion restores the primary terminal to the full tab surface.

This keeps the product focused on a main working context plus a secondary shell/SSH view instead of becoming another generic terminal multiplexer UI.

## Durable intent, fresh processes

GlassPort persists the user-visible layout without pretending that a process can be serialized.

Persisted state can include:

- Workspace metadata;
- tab order and active tab;
- main/companion pane identity;
- semantic Local/SSH Port reference;
- selected Local launch directory.

It deliberately does **not** persist:

- live Session IDs;
- PIDs or PTY state;
- terminal scrollback;
- remote working directory;
- authentication state;
- a claim that an old process is still running.

On relaunch, GlassPort rebuilds fresh runtime Sessions from durable intent.

## OpenSSH boundary

GlassPort does not implement its own SSH protocol.

The system OpenSSH client remains authoritative for:

- authentication;
- host-key handling;
- `ssh_config`;
- ProxyJump / proxy behavior;
- agent and Keychain behavior;
- connection diagnostics emitted by OpenSSH itself.

GlassPort owns the native product shell, process/session lifecycle and sanitized presentation around that trusted system tool.

## Current development frontier

The following work is active in stacked/open PRs and is **not presented as merged product state**:

- user-selectable terminal themes;
- per-Workspace and per-Port visual identity;
- native **⌘K Command Palette**;
- workspace Quick Actions;
- read-only SSH Connection Inspector based on `ssh -G`;
- more truthful SSH exit/restart presentation;
- sanitized local SSH-agent / Keychain-related diagnostics;
- managed localhost SSH tunnels.

These slices remain behind Mac build/test, privacy/security and/or physical UI acceptance gates before they can join the accepted baseline.

## Engineering principles

### Use the platform and trusted system tools

SwiftTerm renders terminals. PTYs own actual local processes. System OpenSSH owns SSH protocol/security behavior. GlassPort does not duplicate those responsibilities merely to look integrated.

### Persist intent, not runtime machinery

Durable UI/product state and ephemeral process state are intentionally different models.

### Truthful runtime status

A running OpenSSH process is not automatically a verified authenticated remote connection. Exit code 255 is not automatically a specific network/password/host-key diagnosis. Product copy should expose what is actually known.

### Physical validation matters

Terminal focus, resize, copy/paste, shell exit/restart, SSH behavior, split panes, quit/relaunch restoration and Light/Dark appearance require real macOS product validation in addition to tests.

## Technology

Swift · AppKit · SwiftTerm · PTY/process lifecycle · OpenSSH · Foundation persistence · XCTest · Xcode · native macOS

## What this project demonstrates

GlassPort combines product, native UI and systems concerns:

- developer-tool product design;
- AppKit architecture;
- terminal/PTTY lifecycle;
- trusted system-tool integration;
- durable/ephemeral state separation;
- layout restoration and migration;
- failure-safe persistence;
- native keyboard and interaction design;
- testable security/privacy boundaries;
- physical macOS validation.

## Public boundary

The implementation repository remains private while the product evolves. This showcase documents architecture, verified behavior, current limitations and sanitized evidence without exposing private SSH aliases, host details, credentials, paths or operational configuration.

## Engineering note

**[Durable intent is not runtime state →](https://github.com/Charles-drZ/Charles-drZ/blob/main/engineering-notes/glassport-durable-intent-vs-runtime-state.md)**

A short write-up on why GlassPort persists workspace intent while rebuilding PTYs, processes and SSH Sessions after relaunch.

## Follow the work

For accepted milestones, new public case studies and short engineering notes, follow **[@Charles-drZ](https://github.com/Charles-drZ)**.

## Related work

- [Developer profile](https://github.com/Charles-drZ)
- [Glassoft Agent Runtime](https://github.com/Charles-drZ/glassoft-agent-runtime-showcase)
- [NodeMedic](https://github.com/Charles-drZ/nodemedic-showcase)
- [Raspberry Home](https://github.com/Charles-drZ/raspberry-home-showcase)
