import SwiftUI

struct ActionBar: View {
    @Bindable var model: GameViewModel

    var body: some View {
        HStack(spacing: 16) {
            CircleIconButton(systemName: "arrow.uturn.backward",
                             disabled: model.game.undoStack.isEmpty) {
                model.undo()
            }
            CircleIconButton(systemName: "eraser") {
                model.erase()
            }
            CircleIconButton(systemName: "pencil",
                             badgeText: model.game.pencilMode ? "ON" : "OFF",
                             badgeColor: model.game.pencilMode ? Theme.accent : Theme.textMuted) {
                model.togglePencil()
            }
            CircleIconButton(systemName: "lightbulb",
                             badgeText: "\(model.game.hintsRemaining)",
                             badgeColor: model.game.hintsRemaining > 0 ? Theme.accentDeep : Theme.textMuted,
                             disabled: model.game.hintsRemaining == 0) {
                model.useHint()
            }
        }
    }
}

private struct CircleIconButton: View {
    let systemName: String
    var badgeText: String? = nil
    var badgeColor: Color = Theme.accent
    var disabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle().fill(Theme.buttonBackground)
                    Image(systemName: systemName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(disabled ? Theme.textMuted.opacity(0.5) : Theme.accent)
                }
                .frame(width: 56, height: 56)

                if let txt = badgeText {
                    Text(txt)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(badgeColor))
                        .offset(x: 4, y: -4)
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }
}
