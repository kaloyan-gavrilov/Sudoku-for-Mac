import SwiftUI

struct NumberPadView: View {
    @Bindable var model: GameViewModel

    var body: some View {
        let counts = model.game.digitPlacementCounts
        VStack(spacing: 10) {
            ForEach(0..<3) { row in
                HStack(spacing: 10) {
                    ForEach(1...3, id: \.self) { col in
                        let digit = row * 3 + col
                        let placed = counts[digit] >= 9
                        DigitButton(digit: digit, dimmed: placed) {
                            model.enterDigit(digit)
                        }
                    }
                }
            }
        }
    }
}

private struct DigitButton: View {
    let digit: Int
    let dimmed: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text("\(digit)")
                .font(.system(size: 40, weight: .regular))
                .foregroundColor(dimmed ? Theme.textMuted.opacity(0.5) : Theme.accent)
                .frame(width: 78, height: 78)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Theme.buttonBackground)
                )
        }
        .buttonStyle(.plain)
        .disabled(dimmed)
    }
}
