import Foundation

// MARK: - Core Types

/// Represents the difficulty level, affecting grid size or clue complexity.
public enum Difficulty: String, Codable, CaseIterable {
    case easy
    case medium
    case hard
}

/// A unique identifier for a category (e.g., "color", "nation").
public typealias CategoryID = String
/// A unique identifier for an item within a category (e.g., "red", "spain").
public typealias ItemID = String

// MARK: - Logic Rules

/// Represents a logic constraint abstractly, independent of language.
public enum PuzzleRule: Codable, Equatable {
    /// Item A is the same entity as Item B (e.g., "The Brit lives in the Red house").
    /// Params: (Category1, Item1, Category2, Item2)
    case isSame(CategoryID, ItemID, CategoryID, ItemID)

    /// Item A is immediately next to Item B (order unknown).
    /// Params: (Category1, Item1, Category2, Item2)
    case nextTo(CategoryID, ItemID, CategoryID, ItemID)

    /// Item A is somewhere to the left of Item B (smaller house index).
    /// Params: (Category1, Item1, Category2, Item2)
    case leftOf(CategoryID, ItemID, CategoryID, ItemID)

    /// Item A is at a specific absolute position (e.g., "First house").
    /// Params: (Category, Item, Index)
    case atPosition(CategoryID, ItemID, Int)
}

// MARK: - Data Structures

/// Represents a single item (entity) in the puzzle.
public struct PuzzleItem: Codable, Hashable, Identifiable {
    public let id: ItemID
    public let displayValue: String
    public let iconName: String?

    public init(id: ItemID, displayValue: String, iconName: String? = nil) {
        self.id = id
        self.displayValue = displayValue
        self.iconName = iconName
    }
}

/// Represents a category of items (row/column in the logic grid).
public struct PuzzleCategory: Codable, Identifiable {
    public let id: CategoryID
    public let name: String
    public let items: [PuzzleItem]

    public init(id: CategoryID, name: String, items: [PuzzleItem]) {
        self.id = id
        self.name = name
        self.items = items
    }
}

/// Represents a Clue with both text and underlying logic.
public struct PuzzleClue: Codable, Identifiable {
    public let id: String
    public let text: String
    public let rule: PuzzleRule

    public init(id: String, text: String, rule: PuzzleRule) {
        self.id = id
        self.text = text
        self.rule = rule
    }
}

/// The complete Puzzle object.
public struct ZebraPuzzle: Codable, Identifiable {
    public let id: String
    public let difficulty: Difficulty
    public let themeTitle: String
    public let description: String

    public let categories: [PuzzleCategory]
    public let clues: [PuzzleClue]

    /// The solution: Maps CategoryID -> Ordered List of ItemIDs (House 1, House 2...)
    public let solution: [CategoryID: [ItemID]]

    public init(id: String, difficulty: Difficulty, themeTitle: String, description: String, categories: [PuzzleCategory], clues: [PuzzleClue], solution: [CategoryID : [ItemID]]) {
        self.id = id
        self.difficulty = difficulty
        self.themeTitle = themeTitle
        self.description = description
        self.categories = categories
        self.clues = clues
        self.solution = solution
    }
}
