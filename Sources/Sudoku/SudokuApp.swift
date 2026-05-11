import SwiftUI
import AppKit

@main
struct SudokuApp: App {
    @State private var model = GameViewModel()

    init() {
        // When launched outside an .app bundle (e.g. `swift run`) the process
        // defaults to a "background" activation policy and the window never
        // gets focus. Force a regular app policy so the window appears.
        NSApplication.shared.setActivationPolicy(.regular)
    }

    var body: some Scene {
        WindowGroup("Sudoku") {
            ContentView(model: model)
                .onAppear {
                    NSApp.activate(ignoringOtherApps: true)
                }
        }
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Game") {
                    model.startNewGame(difficulty: model.game.difficulty)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            CommandGroup(after: .pasteboard) {
                Divider()
                Button("Undo Move") { model.undo() }
                    .keyboardShortcut("z", modifiers: .command)
                Button("Toggle Pencil") { model.togglePencil() }
                    .keyboardShortcut("p", modifiers: .command)
                Button("Hint") { model.useHint() }
                    .keyboardShortcut("h", modifiers: .command)
                Button("Pause / Resume") { model.togglePause() }
                    .keyboardShortcut(".", modifiers: .command)
            }
        }
    }
}
