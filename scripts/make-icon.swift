#!/usr/bin/env swift
// Renders a 1024x1024 PNG icon for Sudoku for Mac to the path given on argv[1].
// Run via scripts/make-icon.sh — that script also produces the .icns.

import Cocoa

let outputPath = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"
let size: CGFloat = 1024

let img = NSImage(size: NSSize(width: size, height: size))
img.lockFocus()

let rect = NSRect(x: 0, y: 0, width: size, height: size)
let cornerRadius: CGFloat = size * 0.2237  // Apple's recommended squircle radius

// Rounded-square background with a vertical gradient using the app's accent blue.
let bgPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)
bgPath.addClip()

let gradient = NSGradient(colors: [
    NSColor(red: 0.42, green: 0.49, blue: 0.86, alpha: 1),
    NSColor(red: 0.24, green: 0.31, blue: 0.72, alpha: 1)
])!
gradient.draw(in: rect, angle: 270)

// 9x9 grid centered on a comfortable inset.
let gridInset: CGFloat = size * 0.13
let gridRect = rect.insetBy(dx: gridInset, dy: gridInset)
let cellSize = gridRect.width / 9

// Inner grid lines.
NSColor.white.withAlphaComponent(0.55).setStroke()
for i in 1...8 where i % 3 != 0 {
    let line = NSBezierPath()
    line.lineWidth = 3
    let x = gridRect.minX + CGFloat(i) * cellSize
    line.move(to: NSPoint(x: x, y: gridRect.minY))
    line.line(to: NSPoint(x: x, y: gridRect.maxY))
    line.stroke()
    let y = gridRect.minY + CGFloat(i) * cellSize
    let line2 = NSBezierPath()
    line2.lineWidth = 3
    line2.move(to: NSPoint(x: gridRect.minX, y: y))
    line2.line(to: NSPoint(x: gridRect.maxX, y: y))
    line2.stroke()
}

// Heavy 3x3 box dividers.
NSColor.white.setStroke()
for i in [3, 6] {
    let line = NSBezierPath()
    line.lineWidth = 8
    let x = gridRect.minX + CGFloat(i) * cellSize
    line.move(to: NSPoint(x: x, y: gridRect.minY))
    line.line(to: NSPoint(x: x, y: gridRect.maxY))
    line.stroke()
    let y = gridRect.minY + CGFloat(i) * cellSize
    let line2 = NSBezierPath()
    line2.lineWidth = 8
    line2.move(to: NSPoint(x: gridRect.minX, y: y))
    line2.line(to: NSPoint(x: gridRect.maxX, y: y))
    line2.stroke()
}

// Outer border.
let outer = NSBezierPath(rect: gridRect)
outer.lineWidth = 10
outer.stroke()

// A scatter of digits to make the icon recognizable as Sudoku.
// (row, col, digit) — kept consistent with a real Sudoku-like distribution.
let digits: [(Int, Int, String)] = [
    (0, 1, "6"), (0, 4, "3"), (0, 7, "1"),
    (1, 0, "5"), (1, 5, "9"),
    (2, 3, "5"), (2, 8, "2"),
    (3, 1, "9"), (3, 6, "2"),
    (4, 2, "7"), (4, 4, "5"), (4, 6, "9"),
    (5, 0, "3"), (5, 7, "8"),
    (6, 1, "3"), (6, 6, "4"),
    (7, 3, "6"), (7, 7, "5"),
    (8, 4, "7"), (8, 8, "3"),
]

let fontSize = cellSize * 0.62
let font = NSFont.systemFont(ofSize: fontSize, weight: .semibold)
let attrs: [NSAttributedString.Key: Any] = [
    .font: font,
    .foregroundColor: NSColor.white,
]
for (r, c, d) in digits {
    let s = NSAttributedString(string: d, attributes: attrs)
    let textSize = s.size()
    let x = gridRect.minX + CGFloat(c) * cellSize + (cellSize - textSize.width) / 2
    let yTop = gridRect.maxY - CGFloat(r + 1) * cellSize
    let y = yTop + (cellSize - textSize.height) / 2
    s.draw(at: NSPoint(x: x, y: y))
}

img.unlockFocus()

guard let tiff = img.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    FileHandle.standardError.write(Data("Failed to encode PNG\n".utf8))
    exit(1)
}

let url = URL(fileURLWithPath: outputPath)
try png.write(to: url)
print("Wrote \(outputPath) (\(png.count) bytes)")
