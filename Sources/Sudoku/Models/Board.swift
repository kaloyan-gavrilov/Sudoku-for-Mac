import Foundation

/// A 9x9 Sudoku board stored row-major. Index = row * 9 + col.
struct Board: Codable, Equatable {
    var cells: [Cell]

    init(cells: [Cell] = Array(repeating: Cell(), count: 81)) {
        precondition(cells.count == 81)
        self.cells = cells
    }

    static func index(row: Int, col: Int) -> Int { row * 9 + col }
    static func boxIndex(row: Int, col: Int) -> Int { (row / 3) * 3 + (col / 3) }
    static func rowCol(_ i: Int) -> (row: Int, col: Int) { (i / 9, i % 9) }

    subscript(row: Int, col: Int) -> Cell {
        get { cells[Board.index(row: row, col: col)] }
        set { cells[Board.index(row: row, col: col)] = newValue }
    }

    /// Returns true when every cell has a non-zero value (regardless of correctness).
    var isFilled: Bool { cells.allSatisfy { !$0.isEmpty } }
}
