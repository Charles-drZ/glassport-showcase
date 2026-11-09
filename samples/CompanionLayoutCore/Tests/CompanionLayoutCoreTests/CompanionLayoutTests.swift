import Foundation
import Testing
@testable import CompanionLayoutCore

struct CompanionLayoutTests {
    private func fixture(target: DemoTarget = .local) -> (layout: CompanionLayout, first: DemoPane) {
        let first = DemoPane(id: UUID(), target: target, runtimeToken: UUID())
        return (CompanionLayout(tabID: UUID(), firstPane: first), first)
    }

    @Test func onePaneIsTheStartingState() {
        let (layout, first) = fixture()
        #expect(layout.panes == [first])
        #expect(layout.focusedPaneID == first.id)
        #expect(!layout.isClosed)
    }

    @Test func splitCreatesIndependentRuntimeButKeepsTarget() {
        var (layout, first) = fixture()
        let newPaneID = UUID()
        let runtime = UUID()
        #expect(layout.split(from: first.id, newPaneID: newPaneID, newRuntimeToken: runtime) == .added)
        #expect(layout.panes.count == 2)
        #expect(layout.panes[0] == first)
        #expect(layout.panes[1].target == first.target)
        #expect(layout.panes[1].id == newPaneID)
        #expect(layout.panes[1].runtimeToken == runtime)
        #expect(layout.panes[1].runtimeToken != first.runtimeToken)
        #expect(layout.focusedPaneID == newPaneID)
    }

    @Test func remoteCompanionDoesNotSilentlySwitchTargets() {
        var (layout, first) = fixture(target: .namedRemote("example-only"))
        #expect(layout.split(from: first.id, newPaneID: UUID(), newRuntimeToken: UUID()) == .added)
        #expect(layout.panes.map(\.target) == [.namedRemote("example-only"), .namedRemote("example-only")])
    }

    @Test func thirdPaneIsRejectedWithoutMutation() {
        var (layout, first) = fixture()
        #expect(layout.split(from: first.id, newPaneID: UUID(), newRuntimeToken: UUID()) == .added)
        let before = layout
        #expect(layout.split(from: first.id, newPaneID: UUID(), newRuntimeToken: UUID()) == .limitReached)
        #expect(layout == before)
    }

    @Test func unknownSourceDoesNotChangeState() {
        var (layout, _) = fixture()
        let before = layout
        #expect(layout.split(from: UUID(), newPaneID: UUID(), newRuntimeToken: UUID()) == .unknownSource)
        #expect(layout == before)
    }

    @Test func repeatedPaneIdentityIsRejected() {
        var (layout, first) = fixture()
        let before = layout
        #expect(layout.split(from: first.id, newPaneID: first.id, newRuntimeToken: UUID()) == .identityCollision)
        #expect(layout == before)
    }

    @Test func reusedRuntimeIdentityIsRejected() {
        var (layout, first) = fixture()
        let before = layout
        #expect(layout.split(from: first.id, newPaneID: UUID(), newRuntimeToken: first.runtimeToken) == .identityCollision)
        #expect(layout == before)
    }

    @Test func focusRejectsUnknownPaneWithoutMutation() {
        var (layout, _) = fixture()
        let before = layout
        let accepted = layout.focus(UUID())
        #expect(!accepted)
        #expect(layout == before)
    }

    @Test func focusCanReturnToOriginalPane() {
        var (layout, first) = fixture()
        #expect(layout.split(from: first.id, newPaneID: UUID(), newRuntimeToken: UUID()) == .added)
        let accepted = layout.focus(first.id)
        #expect(accepted)
        #expect(layout.focusedPaneID == first.id)
    }

    @Test func closingCompanionKeepsOriginalRuntime() {
        var (layout, first) = fixture()
        let companion = UUID()
        #expect(layout.split(from: first.id, newPaneID: companion, newRuntimeToken: UUID()) == .added)
        #expect(layout.close(companion) == .removedPane)
        #expect(layout.panes == [first])
        #expect(layout.focusedPaneID == first.id)
    }

    @Test func closingOriginalKeepsCompanionFocused() {
        var (layout, first) = fixture()
        let companion = UUID()
        #expect(layout.split(from: first.id, newPaneID: companion, newRuntimeToken: UUID()) == .added)
        let accepted = layout.focus(first.id)
        #expect(accepted)
        #expect(layout.close(first.id) == .removedPane)
        #expect(layout.panes.map(\.id) == [companion])
        #expect(layout.focusedPaneID == companion)
    }

    @Test func closingFinalPaneClearsTabState() {
        var (layout, first) = fixture()
        #expect(layout.close(first.id) == .removedFinalPane)
        #expect(layout.panes.isEmpty)
        #expect(layout.focusedPaneID == nil)
        #expect(layout.isClosed)
        #expect(layout.savedIntent == nil)
    }

    @Test func closedTabCannotCreateAnotherPane() {
        var (layout, first) = fixture()
        #expect(layout.close(first.id) == .removedFinalPane)
        #expect(layout.split(from: first.id, newPaneID: UUID(), newRuntimeToken: UUID()) == .tabClosed)
        #expect(layout.isClosed)
    }

    @Test func closeUnknownPaneDoesNotMutateLayout() {
        var (layout, _) = fixture()
        let before = layout
        #expect(layout.close(UUID()) == .unknownPane)
        #expect(layout == before)
    }

    @Test func savedIntentOmitsRuntimeIdentityAndKeepsPaneIdentity() throws {
        var (layout, first) = fixture(target: .namedRemote("demo"))
        let companion = UUID()
        #expect(layout.split(from: first.id, newPaneID: companion, newRuntimeToken: UUID()) == .added)
        let snapshot = try #require(layout.savedIntent)
        #expect(snapshot.id == layout.tabID)
        #expect(snapshot.panes.map(\.id) == [first.id, companion])
        #expect(snapshot.panes.map(\.target) == [.namedRemote("demo"), .namedRemote("demo")])
        #expect(snapshot.focusedPaneID == companion)
        // SavedPaneIntent has no session/runtime token by design.
    }

    @Test func separateTabsCannotMutateEachOthersPanes() {
        var (one, first) = fixture()
        let (two, foreign) = fixture()
        let before = one
        #expect(one.split(from: foreign.id, newPaneID: UUID(), newRuntimeToken: UUID()) == .unknownSource)
        #expect(one == before)
        #expect(two.panes.count == 1)
        #expect(one.focusedPaneID == first.id)
    }
}
