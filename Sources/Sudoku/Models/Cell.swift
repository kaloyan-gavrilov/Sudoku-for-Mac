import Foundation

struct Cell: Codable, Equatable {
    /// 0 means empty.
    var value: Int = 0
    /// Pencil-mark notes 1-9.
    var notes: Set<Int> = []
    /// Givens are part of the starting clues and cannot be edited.
    var isGiven: Bool = false
    /// True when the user entered a wrong value here (kept on screen in red until cleared/undone).
    var isError: Bool = false

    var isEmpty: Bool { value == 0 }
}
