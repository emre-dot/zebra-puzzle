import Foundation

/// Represents the difficulty level of the puzzle
enum Difficulty: String, Codable {
    case easy
    case medium
    case hard
    case expert
}

/// Represents the cultural context of the puzzle
struct CulturalContext: Codable {
    let languageCode: String // e.g., "en-US", "tr-TR", "ja-JP"
    let themeId: String // e.g., "office_startup", "grand_bazaar"
    let title: String
    let description: String
}

/// Represents a single item in the logic grid (e.g., "Red", "Tea", "Smith")
struct PuzzleItem: Codable, Identifiable, Hashable {
    let id: String // Unique identifier for logic mapping (e.g., "color_1", "drink_2")
    let displayValue: String // The localized text to show (e.g., "Red", "Kırmızı")
    let iconName: String? // Optional icon for UI
}

/// Represents a category of items (e.g., "Colors", "Drinks", "Names")
struct PuzzleCategory: Codable, Identifiable {
    let id: String // Unique identifier (e.g., "category_color")
    let name: String // Localized category name
    let items: [PuzzleItem]
}

/// Represents a clue to solve the puzzle
struct PuzzleClue: Codable, Identifiable {
    let id: String
    let text: String // The localized clue text
    // We could add metadata here for the solver engine if needed
    // let logicType: ClueLogicType
}

/// The main Puzzle data structure
struct ZebraPuzzle: Codable, Identifiable {
    let id: String
    let difficulty: Difficulty
    let context: CulturalContext
    let categories: [PuzzleCategory]
    let clues: [PuzzleClue]

    // The solution grid: Map of CategoryID -> [Ordered Items]
    // Or a more complex structure defining relationships
    let solution: [String: [String]]
}
