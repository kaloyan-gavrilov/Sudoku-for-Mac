import Foundation
import Observation

/// Snapshot of mutable game state captured before every user action so Undo
/// can roll back the board, mistakes, hints, and error flags atomically.
struct GameSnapshot: Codable, Equatable {
    let board: Board
    let mistakes: Int
    let hintsRemaining: Int
}

/// Central in-memory game session. SwiftUI views observe this directly.
@Observable
@MainActor
final class GameState {
    // MARK: - Puzzle data
    var board: Board
    var solution: [Int]
    var difficulty: Difficulty

    // MARK: - UI state
    var selectedIndex: Int? = nil
    var pencilMode: Bool = false

    // MARK: - Counters
    var mistakes: Int = 0
    let mistakeLimit: Int = 3
    var hintsRemaining: Int = 3
    let hintLimit: Int = 3

    // MARK: - Timer
    var secondsElapsed: Int = 0
    var isPaused: Bool = false

    // MARK: - Status
    var isGameOver: Bool = false
    var isComplete: Bool = false
    var isGenerating: Bool = false

    // MARK: - History
    var undoStack: [GameSnapshot] = []

    init(puzzle: GeneratedPuzzle, difficulty: Difficulty) {
        var cells = [Cell](repeating: Cell(), count: 81)
        for i in 0..<81 {
            let v = puzzle.puzzle[i]
            cells[i] = Cell(value: v, notes: [], isGiven: v != 0, isError: false)
        }
        self.board = Board(cells: cells)
        self.solution = puzzle.solution
        self.difficulty = difficulty
    }

    init(saved: SavedGame) {
        self.board = saved.board
        self.solution = saved.solution
        self.difficulty = saved.difficulty
        self.mistakes = saved.mistakes
        self.hintsRemaining = saved.hintsRemaining
        self.secondsElapsed = saved.secondsElapsed
        self.undoStack = saved.undoSnapshots
        self.isComplete = saved.isComplete
    }

    // MARK: - Selection

    func select(index: Int?) {
        guard !isPaused, !isComplete else { return }
        selectedIndex = index
    }

    // MARK: - Input

    /// Tap a digit 1...9 from the number pad while a cell is selected.
    func enterDigit(_ digit: Int) {
        guard !isPaused, !isGameOver, !isComplete else { return }
        guard let idx = selectedIndex else { return }
        let cell = board.cells[idx]
        guard !cell.isGiven else { return }
        guard (1...9).contains(digit) else { return }

        pushSnapshot()

        if pencilMode {
            // Toggle the note. Clear any committed value first.
            var updated = cell
            updated.value = 0
            updated.isError = false
            if updated.notes.contains(digit) {
                updated.notes.remove(digit)
            } else {
                updated.notes.insert(digit)
            }
            board.cells[idx] = updated
            return
        }

        // Commit a value.
        var updated = cell
        updated.value = digit
        updated.notes.removeAll()
        if digit == solution[idx] {
            updated.isError = false
            board.cells[idx] = updated
            clearNotesPeers(of: idx, digit: digit)
            checkCompletion()
        } else {
            updated.isError = true
            board.cells[idx] = updated
            mistakes += 1
            if mistakes >= mistakeLimit {
                isGameOver = true
            }
        }
    }

    func erase() {
        guard !isPaused, !isGameOver, !isComplete else { return }
        guard let idx = selectedIndex else { return }
        let cell = board.cells[idx]
        guard !cell.isGiven else { return }
        guard !(cell.isEmpty && cell.notes.isEmpty) else { return }

        pushSnapshot()
        var updated = cell
        updated.value = 0
        updated.notes.removeAll()
        updated.isError = false
        board.cells[idx] = updated
    }

    // MARK: - Pencil / Pause

    func togglePencil() {
        pencilMode.toggle()
    }

    func togglePause() {
        guard !isGameOver, !isComplete else { return }
        isPaused.toggle()
    }

    // MARK: - Undo

    func undo() {
        guard let snap = undoStack.popLast() else { return }
        board = snap.board
        mistakes = snap.mistakes
        hintsRemaining = snap.hintsRemaining
        // If we were game-over and the user undoes, lift the lock.
        if isGameOver, mistakes < mistakeLimit {
            isGameOver = false
        }
        isComplete = false
    }

    // MARK: - Hint

    func useHint() {
        guard !isPaused, !isGameOver, !isComplete else { return }
        guard hintsRemaining > 0 else { return }
        guard let idx = selectedIndex else { return }
        let cell = board.cells[idx]
        guard !cell.isGiven, cell.value != solution[idx] else { return }

        pushSnapshot()
        var updated = cell
        updated.value = solution[idx]
        updated.notes.removeAll()
        updated.isError = false
        updated.isGiven = true  // Lock hinted cell against further edits, like a clue.
        board.cells[idx] = updated
        hintsRemaining -= 1
        clearNotesPeers(of: idx, digit: solution[idx])
        checkCompletion()
    }

    // MARK: - Timer tick

    /// Called from a SwiftUI Timer publisher every second.
    func tick() {
        guard !isPaused, !isGameOver, !isComplete else { return }
        secondsElapsed += 1
    }

    // MARK: - Helpers

    private func pushSnapshot() {
        let snap = GameSnapshot(board: board, mistakes: mistakes, hintsRemaining: hintsRemaining)
        undoStack.append(snap)
        if undoStack.count > 200 {
            undoStack.removeFirst(undoStack.count - 200)
        }
    }

    /// When a digit is committed, clear it from notes of cells sharing the same row/col/box.
    private func clearNotesPeers(of idx: Int, digit: Int) {
        let r = idx / 9, c = idx % 9
        let boxR = (r / 3) * 3, boxC = (c / 3) * 3
        for col in 0..<9 {
            let i = r * 9 + col
            if i != idx { board.cells[i].notes.remove(digit) }
        }
        for row in 0..<9 {
            let i = row * 9 + c
            if i != idx { board.cells[i].notes.remove(digit) }
        }
        for dr in 0..<3 {
            for dc in 0..<3 {
                let i = (boxR + dr) * 9 + (boxC + dc)
                if i != idx { board.cells[i].notes.remove(digit) }
            }
        }
    }

    private func checkCompletion() {
        for i in 0..<81 where board.cells[i].value != solution[i] { return }
        isComplete = true
    }

    // MARK: - Derived views

    /// Counts how many of each digit (1...9) are placed correctly on the board.
    /// Used by NumberPadView to dim digits that are fully placed.
    var digitPlacementCounts: [Int] {
        var counts = [Int](repeating: 0, count: 10) // index 0 unused
        for cell in board.cells where cell.value != 0 && !cell.isError {
            counts[cell.value] += 1
        }
        return counts
    }
}
