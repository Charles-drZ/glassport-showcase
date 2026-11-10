import Foundation
import Testing
@testable import WorkspaceRestoreCore

struct RestorePlannerTests {
    private func space(_ id: UUID, title: String = "Project", canvas: Any? = nil) -> [String: Any] {
        var value: [String: Any] = ["id": id.uuidString, "title": title]
        if let canvas { value["canvas"] = canvas }
        return value
    }

    private func canvas(_ primary: UUID, companion: UUID? = nil, focused: UUID? = nil) -> [String: Any] {
        var tiles: [[String: Any]] = [["id": primary.uuidString, "role": "primary"]]
        if let companion { tiles.append(["id": companion.uuidString, "role": "companion"]) }
        return ["tiles": tiles, "focusedTileID": (focused ?? primary).uuidString]
    }

    private func data(
        revision: Int = 2,
        spaces: [[String: Any]],
        selected: UUID
    ) throws -> Data {
        try JSONSerialization.data(withJSONObject: [
            "revision": revision,
            "spaces": spaces,
            "selectedSpaceID": selected.uuidString
        ])
    }

    private func expectError(_ expected: RestoreError, data: Data) {
        do {
            _ = try RestorePlanner.restore(data)
            Issue.record("Expected restore to reject invalid document")
        } catch let error as RestoreError {
            #expect(error == expected)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func legacyMetadataMigratesWithoutInventingLayouts() throws {
        let id = UUID()
        let report = try RestorePlanner.restore(data(
            revision: 1, spaces: [space(id, title: "Legacy")], selected: id
        ))
        #expect(report.migratedFromLegacy)
        #expect(report.document.revision == 2)
        #expect(report.document.spaces[0].id == id)
        #expect(report.document.spaces[0].title == "Legacy")
        #expect(report.document.spaces[0].canvas == nil)
    }

    @Test func validTwoTileCanvasRetainsSelectionAndOrder() throws {
        let id = UUID(), first = UUID(), second = UUID()
        let report = try RestorePlanner.restore(data(
            spaces: [space(id, canvas: canvas(first, companion: second, focused: second))],
            selected: id
        ))
        let output = try #require(report.document.spaces.first?.canvas)
        #expect(output.tiles.map(\.id) == [first, second])
        #expect(output.focusedTileID == second)
        #expect(report.skippedCanvasIDs.isEmpty)
        #expect(!report.migratedFromLegacy)
    }

    @Test func missingLayoutIsValidAndDoesNotBecomeASession() throws {
        let id = UUID()
        let report = try RestorePlanner.restore(data(spaces: [space(id)], selected: id))
        #expect(report.document.spaces[0].canvas == nil)
        #expect(report.skippedCanvasIDs.isEmpty)
    }

    @Test func malformedCanvasValueKeepsWorkspaceMetadata() throws {
        let id = UUID()
        let report = try RestorePlanner.restore(data(
            spaces: [space(id, title: "Keep This", canvas: "invalid fragment")],
            selected: id
        ))
        #expect(report.document.spaces[0].title == "Keep This")
        #expect(report.document.spaces[0].id == id)
        #expect(report.document.spaces[0].canvas == nil)
        #expect(report.skippedCanvasIDs == [id])
    }

    @Test func tooManyTilesInvalidateOnlyThatCanvas() throws {
        let id = UUID()
        var payload = canvas(UUID(), companion: UUID())
        var tiles = payload["tiles"] as! [[String: Any]]
        tiles.append(["id": UUID().uuidString, "role": "companion"])
        payload["tiles"] = tiles
        let report = try RestorePlanner.restore(data(
            spaces: [space(id, canvas: payload)], selected: id
        ))
        #expect(report.skippedCanvasIDs == [id])
        #expect(report.document.spaces.count == 1)
        #expect(report.document.spaces[0].canvas == nil)
    }

    @Test func unknownFocusedTileInvalidatesCanvas() throws {
        let id = UUID()
        let report = try RestorePlanner.restore(data(
            spaces: [space(id, canvas: canvas(UUID(), focused: UUID()))], selected: id
        ))
        #expect(report.skippedCanvasIDs == [id])
    }

    @Test func duplicateTileIdentityInvalidatesCanvas() throws {
        let id = UUID(), duplicate = UUID()
        let report = try RestorePlanner.restore(data(
            spaces: [space(id, canvas: canvas(duplicate, companion: duplicate))], selected: id
        ))
        #expect(report.skippedCanvasIDs == [id])
    }

    @Test func invalidRolesInvalidateCanvasEvenWithValidFocus() throws {
        let id = UUID(), onlyTile = UUID()
        let payload: [String: Any] = [
            "tiles": [["id": onlyTile.uuidString, "role": "companion"]],
            "focusedTileID": onlyTile.uuidString
        ]
        let report = try RestorePlanner.restore(data(
            spaces: [space(id, canvas: payload)], selected: id
        ))
        #expect(report.skippedCanvasIDs == [id])
    }

    @Test func unknownTileRoleIsIsolatedAsMalformedCanvas() throws {
        let id = UUID(), tile = UUID()
        let payload: [String: Any] = [
            "tiles": [["id": tile.uuidString, "role": "unknown-role"]],
            "focusedTileID": tile.uuidString
        ]
        let report = try RestorePlanner.restore(data(
            spaces: [space(id, title: "Retain Name", canvas: payload)], selected: id
        ))
        #expect(report.document.spaces[0].title == "Retain Name")
        #expect(report.document.spaces[0].canvas == nil)
        #expect(report.skippedCanvasIDs == [id])
    }

    @Test func explicitlyNullCanvasIsNotReportedAsCorruption() throws {
        let id = UUID()
        var record = space(id)
        record["canvas"] = NSNull()
        let report = try RestorePlanner.restore(data(
            spaces: [record], selected: id
        ))
        #expect(report.document.spaces[0].canvas == nil)
        #expect(report.skippedCanvasIDs.isEmpty)
    }

    @Test func damagedCanvasDoesNotDamageAnotherWorkspace() throws {
        let bad = UUID(), good = UUID(), mainTile = UUID()
        let report = try RestorePlanner.restore(data(
            spaces: [
                space(bad, title: "Damaged", canvas: ["tiles": "wrong"]),
                space(good, title: "Healthy", canvas: canvas(mainTile))
            ],
            selected: good
        ))
        #expect(report.document.spaces.map(\.title) == ["Damaged", "Healthy"])
        #expect(report.document.spaces[0].canvas == nil)
        #expect(report.document.spaces[1].canvas?.tiles.first?.id == mainTile)
        #expect(report.skippedCanvasIDs == [bad])
        #expect(report.document.selectedSpaceID == good)
    }

    @Test func emptyWorkspaceCollectionIsRejected() throws {
        let id = UUID()
        expectError(.emptyCollection, data: try data(spaces: [], selected: id))
    }

    @Test func duplicateWorkspaceIDsAreRejected() throws {
        let id = UUID()
        expectError(.duplicateSpaceID, data: try data(
            spaces: [space(id, title: "One"), space(id, title: "Two")], selected: id
        ))
    }

    @Test func blankWorkspaceTitleIsRejected() throws {
        let id = UUID()
        expectError(.invalidTitle, data: try data(
            spaces: [space(id, title: "   ")], selected: id
        ))
    }

    @Test func unknownSelectedWorkspaceIsRejected() throws {
        let id = UUID()
        expectError(.invalidSelection, data: try data(
            spaces: [space(id)], selected: UUID()
        ))
    }

    @Test func futureRevisionIsNotSilentlyInterpreted() throws {
        let id = UUID()
        expectError(.unsupportedRevision(99), data: try data(
            revision: 99, spaces: [space(id)], selected: id
        ))
    }

    @Test func malformedRootDocumentIsRejected() {
        expectError(.invalidInput, data: Data("not-json".utf8))
    }

    @Test func resultContainsNoRuntimeProcessesOrCredentials() throws {
        let id = UUID(), tileID = UUID()
        let report = try RestorePlanner.restore(data(
            spaces: [space(id, canvas: canvas(tileID))], selected: id
        ))
        let output = try JSONEncoder().encode(report.document)
        let text = String(decoding: output, as: UTF8.self)
        #expect(!text.contains("runtimeToken"))
        #expect(!text.contains("processID"))
        #expect(!text.contains("credential"))
        #expect(report.document.spaces[0].canvas?.tiles.first?.id == tileID)
    }
}
