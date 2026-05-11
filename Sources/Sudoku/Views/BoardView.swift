import SwiftUI

struct BoardView: View {
    @Bindable var model: GameViewModel

    var body: some View {
        let board = model.game.board
        let selected = model.game.selectedIndex
        let selectedDigit: Int? = selected.map { board.cells[$0].value }

        ZStack {
            // Cells
            VStack(spacing: 0) {
                ForEach(0..<9, id: \.self) { r in
                    HStack(spacing: 0) {
                        ForEach(0..<9, id: \.self) { c in
                            let idx = Board.index(row: r, col: c)
                            CellView(
                                cell: board.cells[idx],
                                index: idx,
                                selectedIndex: selected,
                                selectedDigit: selectedDigit
                            ) {
                                model.select(index: idx)
                            }
                        }
                    }
                }
            }
            // Grid lines on top
            GridLinesOverlay()
                .allowsHitTesting(false)
        }
        .frame(width: Theme.boardSize, height: Theme.boardSize)
        .background(Color.white)
        .overlay(
            Rectangle().stroke(Theme.gridLineHeavy, lineWidth: 2)
        )
        .blur(radius: model.game.isPaused ? 8 : 0)
        .overlay(pauseOverlay)
    }

    @ViewBuilder
    private var pauseOverlay: some View {
        if model.game.isPaused {
            ZStack {
                Color.white.opacity(0.6)
                VStack(spacing: 12) {
                    Image(systemName: "pause.circle.fill")
                        .font(.system(size: 48))
                        .foregroundColor(Theme.accent)
                    Text("Paused").font(.title3).foregroundColor(Theme.textPrimary)
                }
            }
        }
    }
}

private struct GridLinesOverlay: View {
    var body: some View {
        ZStack {
            // Light interior lines
            ForEach(1..<9) { i in
                if i % 3 != 0 {
                    Rectangle()
                        .fill(Theme.gridLineLight)
                        .frame(width: 1)
                        .offset(x: CGFloat(i) * Theme.cellSize - Theme.boardSize / 2)
                    Rectangle()
                        .fill(Theme.gridLineLight)
                        .frame(height: 1)
                        .offset(y: CGFloat(i) * Theme.cellSize - Theme.boardSize / 2)
                }
            }
            // Heavy box dividers (every 3 cells)
            ForEach([3, 6], id: \.self) { i in
                Rectangle()
                    .fill(Theme.gridLineHeavy)
                    .frame(width: 1.5)
                    .offset(x: CGFloat(i) * Theme.cellSize - Theme.boardSize / 2)
                Rectangle()
                    .fill(Theme.gridLineHeavy)
                    .frame(height: 1.5)
                    .offset(y: CGFloat(i) * Theme.cellSize - Theme.boardSize / 2)
            }
        }
        .frame(width: Theme.boardSize, height: Theme.boardSize)
    }
}
