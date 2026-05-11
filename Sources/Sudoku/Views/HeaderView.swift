import SwiftUI

struct HeaderView: View {
    @Bindable var model: GameViewModel
    @Binding var pendingDifficulty: Difficulty?

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(spacing: 14) {
                Text("Difficulty:")
                    .font(.system(size: 16))
                    .foregroundColor(Theme.textMuted)

                ForEach(Difficulty.allCases) { diff in
                    let active = diff == model.game.difficulty
                    Button(action: {
                        if diff == model.game.difficulty { return }
                        if model.game.isComplete {
                            model.startNewGame(difficulty: diff)
                        } else {
                            pendingDifficulty = diff
                        }
                    }) {
                        Text(diff.displayName)
                            .font(.system(size: 16, weight: active ? .bold : .regular))
                            .foregroundColor(active ? Theme.accent : Theme.textPrimary)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer()

            Text("\(score)")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(Theme.textPrimary)
        }
    }

    /// Simple score: clues filled correctly (excluding givens), minus 50 per mistake.
    /// Stays non-negative so the UI doesn't look weird mid-game.
    private var score: Int {
        let board = model.game.board
        let solution = model.game.solution
        var correct = 0
        for i in 0..<81 {
            let cell = board.cells[i]
            if !cell.isGiven && cell.value != 0 && cell.value == solution[i] {
                correct += 1
            }
        }
        let penalty = model.game.mistakes * 50
        return max(0, correct * 10 - penalty)
    }
}
