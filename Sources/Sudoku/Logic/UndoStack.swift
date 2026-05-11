import Foundation

/// Bounded LIFO stack used to snapshot game state before each mutating action
/// so Undo can roll back values, notes, mistake count, etc.
struct UndoStack<T> {
    private(set) var items: [T] = []
    let limit: Int

    init(limit: Int = 200) {
        self.limit = limit
    }

    var isEmpty: Bool { items.isEmpty }
    var count: Int { items.count }

    mutating func push(_ item: T) {
        items.append(item)
        if items.count > limit {
            items.removeFirst(items.count - limit)
        }
    }

    mutating func pop() -> T? {
        items.popLast()
    }

    mutating func clear() {
        items.removeAll(keepingCapacity: true)
    }
}
