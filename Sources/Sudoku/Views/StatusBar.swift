import SwiftUI

struct StatusBar: View {
    @Bindable var model: GameViewModel

    var body: some View {
        HStack(alignment: .top, spacing: 24) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Mistakes").font(.system(size: 12)).foregroundColor(Theme.textMuted)
                Text("\(model.game.mistakes)/\(model.game.mistakeLimit)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text("Time").font(.system(size: 12)).foregroundColor(Theme.textMuted)
                Text(formattedTime)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Theme.textPrimary)
                    .monospacedDigit()
            }

            Button(action: { model.togglePause() }) {
                ZStack {
                    Circle().fill(Theme.buttonBackground).frame(width: 30, height: 30)
                    Image(systemName: model.game.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Theme.textPrimary)
                }
            }
            .buttonStyle(.plain)
        }
    }

    private var formattedTime: String {
        let s = model.game.secondsElapsed
        let m = s / 60
        let r = s % 60
        return String(format: "%02d:%02d", m, r)
    }
}
