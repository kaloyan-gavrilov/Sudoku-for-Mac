import SwiftUI

struct CellView: View {
    let cell: Cell
    let index: Int
    let selectedIndex: Int?
    let selectedDigit: Int?  // value at the selected cell (or 0 if empty / nil)
    let onTap: () -> Void

    var body: some View {
        ZStack {
            background
            content
        }
        .frame(width: Theme.cellSize, height: Theme.cellSize)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }

    // MARK: - Background highlight tiers

    private var background: some View {
        Rectangle().fill(backgroundColor)
    }

    private var backgroundColor: Color {
        if cell.isError { return Theme.cellErrorBg }
        guard let sel = selectedIndex else { return .white }
        let (sr, sc) = Board.rowCol(sel)
        let (r, c)   = Board.rowCol(index)
        let sameRow = sr == r
        let sameCol = sc == c
        let sameBox = (sr / 3 == r / 3) && (sc / 3 == c / 3)

        if index == sel {
            return Theme.cellSelected
        }
        // Same-digit highlight (only if the selected cell has a value and this cell shares it).
        if let d = selectedDigit, d != 0, cell.value == d {
            return Theme.cellSameDigit
        }
        if sameRow || sameCol || sameBox {
            return Theme.cellHighlight
        }
        return .white
    }

    // MARK: - Content (value or notes)

    @ViewBuilder
    private var content: some View {
        if cell.value != 0 {
            Text("\(cell.value)")
                .font(.system(size: 28, weight: cell.isGiven ? .semibold : .regular))
                .foregroundColor(valueColor)
        } else if !cell.notes.isEmpty {
            NotesGrid(notes: cell.notes)
                .padding(3)
        }
    }

    private var valueColor: Color {
        if cell.isError { return Theme.error }
        return cell.isGiven ? Theme.textGiven : Theme.accent
    }
}

private struct NotesGrid: View {
    let notes: Set<Int>
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<3) { row in
                HStack(spacing: 0) {
                    ForEach(0..<3) { col in
                        let n = row * 3 + col + 1
                        Text(notes.contains(n) ? "\(n)" : " ")
                            .font(.system(size: 11, weight: .regular))
                            .foregroundColor(Theme.textNote)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
        }
    }
}
