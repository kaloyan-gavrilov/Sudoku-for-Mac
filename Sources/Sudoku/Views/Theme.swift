import SwiftUI

/// Centralized colors and metrics so the look stays consistent across views
/// and matches the reference screenshot.
enum Theme {
    // Accents
    static let accent       = Color(red: 0.29, green: 0.36, blue: 0.75) // ~#4A5BBF
    static let accentDeep   = Color(red: 0.36, green: 0.43, blue: 0.78)
    static let textPrimary  = Color(red: 0.13, green: 0.18, blue: 0.32) // dark navy
    static let textGiven    = Color(red: 0.13, green: 0.18, blue: 0.32)
    static let textNote     = Color(red: 0.45, green: 0.50, blue: 0.60)
    static let textMuted    = Color(red: 0.55, green: 0.60, blue: 0.68)
    static let error        = Color(red: 0.88, green: 0.30, blue: 0.30)

    // Backgrounds
    static let appBackground   = Color(red: 0.99, green: 0.99, blue: 1.00)
    static let cellHighlight   = Color(red: 0.92, green: 0.94, blue: 0.99)
    static let cellSameDigit   = Color(red: 0.83, green: 0.88, blue: 0.98)
    static let cellSelected    = Color(red: 0.74, green: 0.82, blue: 0.97)
    static let cellErrorBg     = Color(red: 1.00, green: 0.88, blue: 0.88)
    static let buttonBackground = Color(red: 0.93, green: 0.95, blue: 0.99)

    // Grid
    static let gridLineLight   = Color(red: 0.82, green: 0.85, blue: 0.90)
    static let gridLineHeavy   = Color(red: 0.30, green: 0.34, blue: 0.45)

    // Metrics
    static let cellSize: CGFloat = 56
    static let boardSize: CGFloat = cellSize * 9
}
