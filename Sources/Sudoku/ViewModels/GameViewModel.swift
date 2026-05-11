import Foundation
import Observation

/// Top-level app model. Owns the active `GameState`, drives the timer, and
/// handles async puzzle generation and disk persistence so views never have to.
@Observable
@MainActor
final class GameViewModel {

    private(set) var game: GameState
    /// True while a new puzzle is generating in the background.
    var isGenerating: Bool = false

    private var timerTask: Task<Void, Never>?
    private var saveTask: Task<Void, Never>?

    init() {
        // Try to resume an in-progress game, else fall back to a fresh Easy puzzle.
        if let saved = SaveStore.load() {
            self.game = GameState(saved: saved)
        } else {
            let puzzle = Generator.generate(difficulty: .easy)
            self.game = GameState(puzzle: puzzle, difficulty: .easy)
        }
        startTimer()
    }

    // MARK: - New game

    func startNewGame(difficulty: Difficulty) {
        isGenerating = true
        Task { [weak self] in
            // Generate off the main actor so the UI stays responsive on hard
            // difficulties (Extreme can take a few hundred ms).
            let puzzle = await Task.detached(priority: .userInitiated) {
                Generator.generate(difficulty: difficulty)
            }.value
            guard let self else { return }
            self.game = GameState(puzzle: puzzle, difficulty: difficulty)
            self.isGenerating = false
            self.persist()
        }
    }

    // MARK: - Timer

    private func startTimer() {
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard let self else { return }
                self.game.tick()
            }
        }
    }

    // MARK: - Persistence (debounced)

    func persist() {
        saveTask?.cancel()
        saveTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 800_000_000)
            guard let self, !Task.isCancelled else { return }
            let saved = SavedGame(
                board: self.game.board,
                solution: self.game.solution,
                difficulty: self.game.difficulty,
                mistakes: self.game.mistakes,
                hintsRemaining: self.game.hintsRemaining,
                secondsElapsed: self.game.secondsElapsed,
                undoSnapshots: self.game.undoStack,
                isComplete: self.game.isComplete
            )
            await Task.detached(priority: .background) {
                SaveStore.save(saved)
            }.value
        }
    }

    // MARK: - User actions (forwarded so view code can call one place + auto-persist)

    func select(index: Int?) {
        game.select(index: index)
    }

    func enterDigit(_ d: Int) {
        game.enterDigit(d)
        persist()
    }

    func erase() {
        game.erase()
        persist()
    }

    func togglePencil() {
        game.togglePencil()
    }

    func togglePause() {
        game.togglePause()
    }

    func undo() {
        game.undo()
        persist()
    }

    func useHint() {
        game.useHint()
        persist()
    }
}
