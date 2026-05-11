# Sudoku for Mac

A lightweight, native macOS Sudoku game built with SwiftUI. No Electron, no web view — just a few megabytes of pure Swift.

## Features

- **Five difficulty levels** — Easy, Medium, Hard, Expert, Extreme — generated on the fly with a guaranteed unique solution.
- **Smart highlighting** — selecting a cell tints its row, column, and 3×3 box; selecting a digit also highlights every other cell containing that digit.
- **Pencil marks** — toggle pencil mode to jot notes (1–9) inside a cell.
- **3 hints per game** — fills the selected empty cell with the correct value.
- **Mistake tracker** — 3 strikes ends the game, but you can always **Undo** to continue.
- **Undo stack** — step back through every move.
- **Timer & pause** — pausing blurs the board so you can't peek.
- **Auto-save** — the in-progress game is persisted to `~/Library/Application Support/SudokuForMac/` and resumed on next launch.
- **Keyboard shortcuts** — full mouse-free play (see below).

## Requirements

- macOS 14 (Sonoma) or later
- Swift 5.9+ / Xcode 15+ (only needed to build from source — once built, the `.app` runs standalone)

## Build & Run

### Quick (development)

```bash
swift run Sudoku
```

### Build a distributable `.app`

```bash
./build-app.sh
open dist/Sudoku.app
```

This produces a universal binary (`arm64` + `x86_64`) bundled as `dist/Sudoku.app`. Drag it into `/Applications` to keep it around:

```bash
cp -R dist/Sudoku.app /Applications/
```

## Keyboard shortcuts

| Key                       | Action                       |
|---------------------------|------------------------------|
| `1`–`9`                   | Enter digit / toggle note    |
| `Delete` / `Backspace`    | Erase selected cell          |
| `Space`                   | Toggle pencil mode           |
| Arrow keys                | Move selection               |
| `⌘N`                      | New game                     |
| `⌘Z`                      | Undo                         |
| `⌘P`                      | Toggle pencil                |
| `⌘H`                      | Use hint                     |
| `⌘.`                      | Pause / resume               |

## How it works

- **Generation** — fills the three diagonal 3×3 boxes with shuffled digits (they don't constrain each other), backtracks to complete the grid, then digs holes one at a time while verifying via a counting solver that the puzzle still has exactly one solution.
- **Solver** — most-constrained-variable backtracking with bitmask candidate sets.
- **State** — a single `@Observable` `GameState` drives every view; user actions push snapshots onto an undo stack so any mistake can be rolled back.

## Project layout

```
Sources/Sudoku/
├── SudokuApp.swift          # @main entry point
├── Models/                  # Cell, Board, Difficulty, GameState
├── Logic/                   # Generator, Solver, UndoStack
├── Persistence/             # SaveStore (JSON to Application Support)
├── ViewModels/              # GameViewModel
└── Views/                   # BoardView, CellView, ActionBar, etc.
```

## License

MIT
