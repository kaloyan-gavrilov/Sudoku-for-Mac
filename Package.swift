// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Sudoku",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "Sudoku", targets: ["Sudoku"])
    ],
    targets: [
        .executableTarget(
            name: "Sudoku",
            path: "Sources/Sudoku"
        )
    ]
)
