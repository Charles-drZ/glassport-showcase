import Foundation

/// An original, platform-independent portfolio example. These JSON fields and
/// types are not the GlassPort application's persistence schema.

public struct SavedTile: Codable, Equatable, Sendable {
    public enum Role: String, Codable, Sendable {
        case primary
        case companion
    }

    public let id: UUID
    public let role: Role
}

public struct SavedCanvas: Codable, Equatable, Sendable {
    public let tiles: [SavedTile]
    public let focusedTileID: UUID

    fileprivate var isValid: Bool {
        guard (1...2).contains(tiles.count) else { return false }
        guard Set(tiles.map(\.id)).count == tiles.count else { return false }
        guard tiles.contains(where: { $0.id == focusedTileID }) else { return false }
        let primaryCount = tiles.filter { $0.role == .primary }.count
        let companionCount = tiles.filter { $0.role == .companion }.count
        return primaryCount == 1 && companionCount == tiles.count - 1
    }
}

public struct SavedSpace: Codable, Equatable, Sendable {
    public let id: UUID
    public let title: String
    public let canvas: SavedCanvas?
}

public struct SavedWorkspaceDocument: Codable, Equatable, Sendable {
    public let revision: Int
    public let spaces: [SavedSpace]
    public let selectedSpaceID: UUID
}

public struct RestoreReport: Sendable {
    public let document: SavedWorkspaceDocument
    public let skippedCanvasIDs: [UUID]
    public let migratedFromLegacy: Bool
}

public enum RestoreError: Error, Equatable, Sendable {
    case invalidInput
    case unsupportedRevision(Int)
    case emptyCollection
    case duplicateSpaceID
    case invalidTitle
    case invalidSelection
}

/// Decoding is read-only: no files, running processes or credentials are touched.
/// A malformed layout fragment can be ignored without silently losing its
/// surrounding workspace title and identity.
public enum RestorePlanner {
    public static func restore(_ data: Data) throws -> RestoreReport {
        let source: IncomingDocument
        do {
            source = try JSONDecoder().decode(IncomingDocument.self, from: data)
        } catch let error as RestoreError {
            throw error
        } catch {
            throw RestoreError.invalidInput
        }

        guard !source.spaces.isEmpty else { throw RestoreError.emptyCollection }
        let ids = source.spaces.map(\.id)
        guard Set(ids).count == ids.count else { throw RestoreError.duplicateSpaceID }
        guard source.spaces.allSatisfy({
            !$0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }) else {
            throw RestoreError.invalidTitle
        }
        guard ids.contains(source.selectedSpaceID) else {
            throw RestoreError.invalidSelection
        }

        var rejected: [UUID] = []
        let normalized = source.spaces.map { incoming -> SavedSpace in
            // Illustrative legacy revision had only names and identifiers.
            // Any layout field from that revision is deliberately ignored.
            let canvas = source.revision == 1 ? nil : incoming.canvas
            if source.revision == 2 &&
                (incoming.invalidCanvasField || (canvas != nil && canvas?.isValid == false)) {
                rejected.append(incoming.id)
                return SavedSpace(id: incoming.id, title: incoming.title, canvas: nil)
            }
            return SavedSpace(id: incoming.id, title: incoming.title, canvas: canvas)
        }

        return RestoreReport(
            document: SavedWorkspaceDocument(
                revision: 2,
                spaces: normalized,
                selectedSpaceID: source.selectedSpaceID
            ),
            skippedCanvasIDs: rejected,
            migratedFromLegacy: source.revision == 1
        )
    }
}

private struct IncomingDocument: Decodable {
    let revision: Int
    let spaces: [IncomingSpace]
    let selectedSpaceID: UUID

    private enum CodingKeys: String, CodingKey {
        case revision
        case spaces
        case selectedSpaceID
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        revision = try values.decode(Int.self, forKey: .revision)
        guard revision == 1 || revision == 2 else {
            throw RestoreError.unsupportedRevision(revision)
        }
        spaces = try values.decode([IncomingSpace].self, forKey: .spaces)
        selectedSpaceID = try values.decode(UUID.self, forKey: .selectedSpaceID)
    }
}

private struct IncomingSpace: Decodable {
    let id: UUID
    let title: String
    let canvas: SavedCanvas?
    let invalidCanvasField: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case canvas
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(UUID.self, forKey: .id)
        title = try values.decode(String.self, forKey: .title)

        if let readable = try? values.decodeIfPresent(SavedCanvas.self, forKey: .canvas) {
            canvas = readable
            invalidCanvasField = false
        } else {
            canvas = nil
            invalidCanvasField = values.contains(.canvas) &&
                (try? values.decodeNil(forKey: .canvas)) != true
        }
    }
}
