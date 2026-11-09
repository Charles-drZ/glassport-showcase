import Foundation

/// An original, self-contained example of two-pane state management.
/// This is NOT extracted from GlassPort and does not manage processes or AppKit views.
public enum DemoTarget: Equatable, Sendable {
    case local
    case namedRemote(String)
}

public struct DemoPane: Equatable, Sendable {
    public let id: UUID
    public let target: DemoTarget
    public let runtimeToken: UUID

    public init(id: UUID, target: DemoTarget, runtimeToken: UUID) {
        self.id = id
        self.target = target
        self.runtimeToken = runtimeToken
    }
}

/// A deliberately small durable *intent* representation.
/// Runtime tokens are not included, because running processes cannot be restored.
public struct SavedPaneIntent: Equatable, Sendable {
    public let id: UUID
    public let target: DemoTarget
}

public struct SavedTabIntent: Equatable, Sendable {
    public let id: UUID
    public let panes: [SavedPaneIntent]
    public let focusedPaneID: UUID
}

public enum SplitOutcome: Equatable, Sendable {
    case added
    case limitReached
    case unknownSource
    case identityCollision
    case tabClosed
}

public enum CloseOutcome: Equatable, Sendable {
    case removedPane
    case removedFinalPane
    case unknownPane
}

/// Value-type demonstration of one main pane and at most one companion.
/// It is not a process manager, terminal integration, or production layout schema.
public struct CompanionLayout: Equatable, Sendable {
    public static let paneLimit = 2

    public let tabID: UUID
    public private(set) var panes: [DemoPane]
    public private(set) var focusedPaneID: UUID?

    public init(tabID: UUID, firstPane: DemoPane) {
        self.tabID = tabID
        self.panes = [firstPane]
        self.focusedPaneID = firstPane.id
    }

    public var isClosed: Bool { panes.isEmpty }

    /// A companion inherits the selected target but must own a distinct
    /// runtime token. All inputs are injected to keep the example deterministic.
    @discardableResult
    public mutating func split(
        from sourcePaneID: UUID,
        newPaneID: UUID,
        newRuntimeToken: UUID
    ) -> SplitOutcome {
        guard !isClosed else { return .tabClosed }
        guard let source = panes.first(where: { $0.id == sourcePaneID }) else {
            return .unknownSource
        }
        guard panes.count < Self.paneLimit else { return .limitReached }
        guard !panes.contains(where: {
            $0.id == newPaneID || $0.runtimeToken == newRuntimeToken
        }) else {
            return .identityCollision
        }

        panes.append(DemoPane(
            id: newPaneID,
            target: source.target,
            runtimeToken: newRuntimeToken
        ))
        focusedPaneID = newPaneID
        return .added
    }

    @discardableResult
    public mutating func focus(_ paneID: UUID) -> Bool {
        guard panes.contains(where: { $0.id == paneID }) else { return false }
        focusedPaneID = paneID
        return true
    }

    @discardableResult
    public mutating func close(_ paneID: UUID) -> CloseOutcome {
        guard let index = panes.firstIndex(where: { $0.id == paneID }) else {
            return .unknownPane
        }
        panes.remove(at: index)
        guard !panes.isEmpty else {
            focusedPaneID = nil
            return .removedFinalPane
        }
        if focusedPaneID == paneID {
            focusedPaneID = panes[0].id
        }
        return .removedPane
    }

    /// Stores user layout intent only. No runtime token, PID, PTY, session
    /// credentials, or terminal output crosses this boundary.
    public var savedIntent: SavedTabIntent? {
        guard let focusedPaneID, !panes.isEmpty else { return nil }
        return SavedTabIntent(
            id: tabID,
            panes: panes.map { SavedPaneIntent(id: $0.id, target: $0.target) },
            focusedPaneID: focusedPaneID
        )
    }
}
