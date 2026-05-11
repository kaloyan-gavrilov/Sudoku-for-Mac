import SwiftUI

struct GameOverOverlay: View {
    @Bindable var model: GameViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "xmark.octagon.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Theme.error)
                Text("Game Over").font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                Text("You reached \(model.game.mistakeLimit) mistakes.")
                    .foregroundColor(Theme.textMuted)

                HStack(spacing: 12) {
                    Button(action: { model.undo() }) {
                        Text("Undo last move")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Theme.accent)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Theme.accent, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(model.game.undoStack.isEmpty)

                    Button(action: {
                        model.startNewGame(difficulty: model.game.difficulty)
                    }) {
                        Text("New Game")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 18).padding(.vertical, 10)
                            .background(RoundedRectangle(cornerRadius: 8).fill(Theme.accent))
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(28)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            .shadow(radius: 18)
        }
    }
}

struct WinOverlay: View {
    @Bindable var model: GameViewModel

    var body: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: 14) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 56))
                    .foregroundColor(Theme.accent)
                Text("Solved!").font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.textPrimary)
                Text("Time: \(formatted(model.game.secondsElapsed)) \u{2022} Mistakes: \(model.game.mistakes)")
                    .foregroundColor(Theme.textMuted)
                Button(action: {
                    model.startNewGame(difficulty: model.game.difficulty)
                }) {
                    Text("New Game")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 22).padding(.vertical, 10)
                        .background(RoundedRectangle(cornerRadius: 8).fill(Theme.accent))
                }
                .buttonStyle(.plain)
            }
            .padding(28)
            .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            .shadow(radius: 18)
        }
    }

    private func formatted(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }
}
