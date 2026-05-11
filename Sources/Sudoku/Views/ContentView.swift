import SwiftUI

struct ContentView: View {
    @Bindable var model: GameViewModel
    @State private var pendingDifficulty: Difficulty? = nil

    var body: some View {
        ZStack {
            Theme.appBackground.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 18) {
                HeaderView(model: model, pendingDifficulty: $pendingDifficulty)

                HStack(alignment: .top, spacing: 28) {
                    BoardView(model: model)

                    VStack(alignment: .leading, spacing: 18) {
                        StatusBar(model: model)
                        ActionBar(model: model)
                        NumberPadView(model: model)
                        Spacer(minLength: 0)
                        NewGameButton(model: model)
                    }
                    .frame(width: 280)
                }
            }
            .padding(24)

            if model.isGenerating {
                ZStack {
                    Color.black.opacity(0.15).ignoresSafeArea()
                    ProgressView("Generating…")
                        .padding(24)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                        .shadow(radius: 8)
                }
            }
            if model.game.isGameOver {
                GameOverOverlay(model: model)
            }
            if model.game.isComplete {
                WinOverlay(model: model)
            }
        }
        .frame(minWidth: 880, minHeight: 620)
        .focusable(true)
        .onKeyPress(phases: .down) { press in
            handleKey(press) ? .handled : .ignored
        }
        .confirmationDialog(
            "Start a new \(pendingDifficulty?.displayName ?? "") game?",
            isPresented: Binding(
                get: { pendingDifficulty != nil },
                set: { if !$0 { pendingDifficulty = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Start New Game", role: .destructive) {
                if let d = pendingDifficulty {
                    model.startNewGame(difficulty: d)
                }
                pendingDifficulty = nil
            }
            Button("Cancel", role: .cancel) { pendingDifficulty = nil }
        } message: {
            Text("Your current game will be discarded.")
        }
    }

    // MARK: - Keyboard

    private func handleKey(_ press: KeyPress) -> Bool {
        // Digits 1-9 commit / toggle note
        if let scalar = press.characters.unicodeScalars.first,
           let digit = Int(String(scalar)),
           (1...9).contains(digit) {
            model.enterDigit(digit)
            return true
        }
        switch press.key {
        case .delete, .deleteForward:
            model.erase()
            return true
        case .space:
            model.togglePencil()
            return true
        case .leftArrow:  moveSelection(dr: 0, dc: -1); return true
        case .rightArrow: moveSelection(dr: 0, dc: 1);  return true
        case .upArrow:    moveSelection(dr: -1, dc: 0); return true
        case .downArrow:  moveSelection(dr: 1, dc: 0);  return true
        default: return false
        }
    }

    private func moveSelection(dr: Int, dc: Int) {
        let current = model.game.selectedIndex ?? 0
        let (r, c) = Board.rowCol(current)
        let nr = min(8, max(0, r + dr))
        let nc = min(8, max(0, c + dc))
        model.select(index: Board.index(row: nr, col: nc))
    }
}

private struct NewGameButton: View {
    @Bindable var model: GameViewModel

    var body: some View {
        Button(action: { model.startNewGame(difficulty: model.game.difficulty) }) {
            Text("New Game")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.accent))
        }
        .buttonStyle(.plain)
    }
}
