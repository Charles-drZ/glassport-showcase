[← GlassPort overview](../README.md)

# A native macOS terminal workspace: intent versus process state

**Swift · AppKit · SwiftTerm · PTY · system OpenSSH**

GlassPort organizes local and remote development around Workspaces, Ports and live Sessions. A Workspace is the user's durable context; a Session is a running process and cannot be serialized across an app relaunch.

## Product model

```text
Workspace
 ├─ Local Shell Port
 │   └─ live Session / PTY
 ├─ SSH Port
 │   └─ live Session / system OpenSSH
 └─ ordered tabs
      ├─ primary terminal
      └─ optional right-side companion terminal
```

A Port describes a target environment; a Session represents one execution of it. GlassPort uses native AppKit for the application shell and SwiftTerm for terminal rendering. It relies on system `ssh`, not a custom SSH protocol implementation.

## What should survive relaunch?

| Persisted user intent | Deliberately transient state |
| --- | --- |
| Workspace identity and selected Workspace | Session identifiers |
| Tab order and active tab | PIDs, PTYs and live processes |
| Primary / optional companion pane identity | Terminal scrollback and history |
| Semantic Local/SSH Port reference | SSH authentication and connection state |
| Local Shell launch directory | Remote working directory |

This separates the **layout the user designed** from the processes that happened to be running.

On relaunch, GlassPort validates the saved blueprint and starts fresh Sessions. A formerly open SSH tab is not proof of an authenticated connection. When a referenced SSH alias has disappeared, the stale pane is skipped safely rather than treated as a live destination.

## Migration and invalid data

The accepted persistence work introduced a versioned layout format. Valid older Workspace data can be migrated into the newer representation. Invalid layout payloads are isolated so that they do not destroy valid Workspace metadata, and an unusable layout can fall back to a safe Local Shell.

This is a deliberate choice: state migration must not turn a recoverable UI layout failure into loss of the Workspace itself.

## Why not save the whole terminal?

Serializing a live process would pretend that operating-system resources outlast their lifecycle. Saving the remote cwd, auth state or a process ID would be particularly misleading.

The alternative is a smaller persistence contract:

```text
saved Workspace intent
   ↓
validate / migrate / discard invalid layout fragments
   ↓
resolve Local or current OpenSSH alias
   ↓
construct new terminal Sessions
```

This supports clear cleanup, less fragile migrations and testable restore semantics.

## Native macOS constraints

The accepted product also includes:

- real Local Shell sessions over PTY and independently live optional companion Sessions;
- native terminal tabs and a draggable AppKit split divider;
- per-session Local Shell launch folders and Restart in Folder;
- truecolor capability with user environment / `NO_COLOR` preservation;
- Light/Dark-safe terminal selection and a dedicated app identity.

The split remains deliberately focused: **one primary terminal and one optional companion**, not an unrestricted tiling grid.

System OpenSSH stays authoritative for SSH configuration, authentication, host keys, ProxyJump and agent behavior. A running `ssh` process is not automatically a verified authenticated connection.

## Validation and limits

The accepted Workspace persistence work included native macOS build/test and physical product review. The private implementation has migration and restoration tests, but this showcase does not publish their source or logs. The independently written [CompanionLayoutCore](../samples/CompanionLayoutCore/) example illustrates bounded pane state, while [WorkspaceRestoreCore](../samples/WorkspaceRestoreCore/) demonstrates isolated malformed-layout handling and a fictional versioned JSON representation. Neither uses the private implementation or reproduces its tests.

No restored tab should be described as a surviving PTY. No new command palette, theme picker, SSH diagnostics, tunnels or skill-driven agent execution is presented as accepted unless separately merged and validated.

**Visual evidence:** the [public showcase](../README.md) includes three real macOS application screenshots: Workspace overview, SSH terminal, and two Local Shell sessions in a companion split. These illustrate visible UI behavior; no mixed-Port split or public release is claimed.

---

[GlassPort overview →](../README.md)  
[Validation and current status →](validation-and-status.md)  
[GlassBox iOS/watchOS →](https://github.com/Charles-drZ/glassbox-showcase)
