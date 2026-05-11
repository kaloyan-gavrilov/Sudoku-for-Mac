import Foundation

/// Backtracking Sudoku solver operating on a flat 81-element Int grid.
/// 0 represents an empty cell; 1...9 are placed values.
enum Solver {

    /// Returns a fully-solved grid, or nil if unsolvable.
    static func solve(_ grid: [Int]) -> [Int]? {
        var g = grid
        return solveInPlace(&g) ? g : nil
    }

    /// Counts solutions up to `cap` (early-exits as soon as `cap` is reached).
    /// Used during hole-digging to verify the puzzle still has a unique solution.
    static func countSolutions(_ grid: [Int], cap: Int = 2) -> Int {
        var g = grid
        var count = 0
        _ = countInPlace(&g, count: &count, cap: cap)
        return count
    }

    // MARK: - Implementation

    @inline(__always)
    private static func solveInPlace(_ g: inout [Int]) -> Bool {
        guard let i = pickCell(g) else { return true }
        let candidates = candidatesFor(g, at: i)
        for v in candidates {
            g[i] = v
            if solveInPlace(&g) { return true }
            g[i] = 0
        }
        return false
    }

    private static func countInPlace(_ g: inout [Int], count: inout Int, cap: Int) -> Bool {
        if count >= cap { return true }
        guard let i = pickCell(g) else {
            count += 1
            return count >= cap
        }
        let candidates = candidatesFor(g, at: i)
        for v in candidates {
            g[i] = v
            if countInPlace(&g, count: &count, cap: cap) {
                g[i] = 0
                return true
            }
            g[i] = 0
        }
        return false
    }

    /// Picks the empty cell with the fewest candidates ("most constrained variable"),
    /// dramatically pruning the search tree. Returns nil when the grid is full.
    private static func pickCell(_ g: [Int]) -> Int? {
        var bestIdx: Int? = nil
        var bestCount = 10
        for i in 0..<81 where g[i] == 0 {
            let c = candidatesFor(g, at: i).count
            if c < bestCount {
                bestCount = c
                bestIdx = i
                if c <= 1 { return bestIdx }
            }
        }
        return bestIdx
    }

    /// Available digits for cell `i` based on its row, column, and box.
    private static func candidatesFor(_ g: [Int], at i: Int) -> [Int] {
        let r = i / 9, c = i % 9
        let boxR = (r / 3) * 3, boxC = (c / 3) * 3
        var used = 0  // bitmask of digits 1...9 in bits 1...9
        for col in 0..<9 { used |= 1 << g[r * 9 + col] }
        for row in 0..<9 { used |= 1 << g[row * 9 + c] }
        for dr in 0..<3 {
            for dc in 0..<3 {
                used |= 1 << g[(boxR + dr) * 9 + (boxC + dc)]
            }
        }
        var out: [Int] = []
        out.reserveCapacity(9)
        for v in 1...9 where (used & (1 << v)) == 0 {
            out.append(v)
        }
        return out
    }
}
