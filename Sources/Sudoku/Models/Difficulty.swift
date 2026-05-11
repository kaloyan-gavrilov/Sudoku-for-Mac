import Foundation

enum Difficulty: String, CaseIterable, Codable, Identifiable {
    case easy
    case medium
    case hard
    case expert
    case extreme

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .easy:    return "Easy"
        case .medium:  return "Medium"
        case .hard:    return "Hard"
        case .expert:  return "Expert"
        case .extreme: return "Extreme"
        }
    }

    /// Target number of given clues remaining after the puzzle is dug out.
    /// We pick a random value in this range per generation.
    var clueRange: ClosedRange<Int> {
        switch self {
        case .easy:    return 40...45
        case .medium:  return 32...36
        case .hard:    return 28...31
        case .expert:  return 25...27
        case .extreme: return 22...24
        }
    }
}
