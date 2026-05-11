import Foundation

struct GeneratedPuzzle {
    let puzzle: [Int]    // 81 ints, 0 = blank
    let solution: [Int]  // 81 ints, full solved board
}

enum Generator {

    /// Build a new puzzle for the given difficulty. Run on a background queue —
    /// Extreme can take a few hundred ms on first try.
    static func generate(difficulty: Difficulty) -> GeneratedPuzzle {
        let solution = randomSolvedBoard()
        let targetClues = Int.random(in: difficulty.clueRange)
        let puzzle = digHoles(from: solution, targetClues: targetClues)
        return GeneratedPuzzle(puzzle: puzzle, solution: solution)
    }

    // MARK: - Solved board

    /// Generates a random fully-solved 9x9 Sudoku grid.
    private static func randomSolvedBoard() -> [Int] {
        var g = [Int](repeating: 0, count: 81)
        // The three diagonal 3x3 boxes don't constrain each other, so we can
        // fill them with independent shuffles of 1...9. Big speed-up.
        for b in 0..<3 {
            let digits = Array(1...9).shuffled()
            var k = 0
            for dr in 0..<3 {
                for dc in 0..<3 {
                    g[(b * 3 + dr) * 9 + (b * 3 + dc)] = digits[k]
                    k += 1
                }
            }
        }
        _ = fillRest(&g)
        return g
    }

    private static func fillRest(_ g: inout [Int]) -> Bool {
        guard let i = (0..<81).first(where: { g[$0] == 0 }) else { return true }
        let r = i / 9, c = i % 9
        let boxR = (r / 3) * 3, boxC = (c / 3) * 3
        var used = 0
        for col in 0..<9 { used |= 1 << g[r * 9 + col] }
        for row in 0..<9 { used |= 1 << g[row * 9 + c] }
        for dr in 0..<3 {
            for dc in 0..<3 { used |= 1 << g[(boxR + dr) * 9 + (boxC + dc)] }
        }
        var candidates: [Int] = []
        for v in 1...9 where (used & (1 << v)) == 0 { candidates.append(v) }
        candidates.shuffle()
        for v in candidates {
            g[i] = v
            if fillRest(&g) { return true }
            g[i] = 0
        }
        return false
    }

    // MARK: - Hole digging

    /// Remove cells in random order; keep a removal only if the puzzle's
    /// solution remains unique. Stop when we reach `targetClues` clues or no
    /// more cells can be safely removed.
    private static func digHoles(from solved: [Int], targetClues: Int) -> [Int] {
        var puzzle = solved
        var indices = Array(0..<81).shuffled()
        var remaining = 81

        while remaining > targetClues, let idx = indices.popLast() {
            let saved = puzzle[idx]
            puzzle[idx] = 0
            if Solver.countSolutions(puzzle, cap: 2) == 1 {
                remaining -= 1
            } else {
                puzzle[idx] = saved
            }
        }
        return puzzle
    }
}
