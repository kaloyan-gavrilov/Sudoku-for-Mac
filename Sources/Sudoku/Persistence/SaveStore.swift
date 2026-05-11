import Foundation

struct SavedGame: Codable {
    var board: Board
    var solution: [Int]
    var difficulty: Difficulty
    var mistakes: Int
    var hintsRemaining: Int
    var secondsElapsed: Int
    var undoSnapshots: [GameSnapshot]
    var isComplete: Bool
}

enum SaveStore {

    private static var fileURL: URL {
        let fm = FileManager.default
        let support = (try? fm.url(for: .applicationSupportDirectory,
                                   in: .userDomainMask,
                                   appropriateFor: nil,
                                   create: true))
            ?? URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Application Support")
        let dir = support.appendingPathComponent("SudokuForMac", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir.appendingPathComponent("savegame.json")
    }

    static func load() -> SavedGame? {
        let url = fileURL
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(SavedGame.self, from: data)
    }

    static func save(_ game: SavedGame) {
        let url = fileURL
        do {
            // Cap snapshots so the file doesn't grow unboundedly.
            var trimmed = game
            if trimmed.undoSnapshots.count > 50 {
                trimmed.undoSnapshots = Array(trimmed.undoSnapshots.suffix(50))
            }
            let data = try JSONEncoder().encode(trimmed)
            try data.write(to: url, options: .atomic)
        } catch {
            // Non-fatal: persistence is best-effort.
        }
    }

    static func clear() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
