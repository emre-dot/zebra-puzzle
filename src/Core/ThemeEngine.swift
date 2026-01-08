import Foundation

// MARK: - Theme Definitions

/// Defines the raw data needed to populate a puzzle for a specific cultural theme.
public struct ThemeDefinition: Codable, Identifiable {
    public let id: String
    public let languageCode: String // e.g., "tr-TR", "en-US"
    public let title: String
    public let description: String

    /// Categories available in this theme.
    /// Key: Category ID (e.g. "drink"), Value: List of localized strings ("Tea", "Coffee"...)
    public let categoryData: [String: ThemeCategoryData]

    /// Templates for generating clue text from rules.
    public let clueTemplates: ClueTemplates
}

public struct ThemeCategoryData: Codable {
    public let name: String // Localized category name (e.g. "İçecekler")
    public let items: [ThemeItemData]
}

public struct ThemeItemData: Codable {
    public let id: String
    public let name: String
    public let icon: String?
}

/// Templates for converting `PuzzleRule` to string.
/// Using placeholders like {item1}, {cat1}, {item2}, {pos}.
public struct ClueTemplates: Codable {
    public let isSame: [String]   // e.g., "{item1} is the one who likes {item2}."
    public let nextTo: [String]   // e.g., "{item1} is next to {item2}."
    public let leftOf: [String]   // e.g., "{item1} is somewhere to the left of {item2}."
    public let atPosition: [String] // e.g., "{item1} is in the {pos} position."
}

// MARK: - Engine

public class ThemeEngine {
    public static let shared = ThemeEngine()

    private var loadedThemes: [String: ThemeDefinition] = [:]

    public init() {}

    public func loadTheme(from url: URL) throws {
        let data = try Data(contentsOf: url)
        let theme = try JSONDecoder().decode(ThemeDefinition.self, from: data)
        loadedThemes[theme.id] = theme
    }

    public func getTheme(id: String) -> ThemeDefinition? {
        return loadedThemes[id]
    }

    /// Generates localized text for a given rule using the theme.
    public func generateClueText(rule: PuzzleRule, theme: ThemeDefinition, categoryMap: [String: PuzzleCategory]) -> String {
        switch rule {
        case .isSame(let c1, let i1, let c2, let i2):
            let template = theme.clueTemplates.isSame.randomElement() ?? "{item1} == {item2}"
            return applyTemplate(template, c1: c1, i1: i1, c2: c2, i2: i2, categoryMap: categoryMap)

        case .nextTo(let c1, let i1, let c2, let i2):
            let template = theme.clueTemplates.nextTo.randomElement() ?? "{item1} next to {item2}"
            return applyTemplate(template, c1: c1, i1: i1, c2: c2, i2: i2, categoryMap: categoryMap)

        case .leftOf(let c1, let i1, let c2, let i2):
            let template = theme.clueTemplates.leftOf.randomElement() ?? "{item1} left of {item2}"
            return applyTemplate(template, c1: c1, i1: i1, c2: c2, i2: i2, categoryMap: categoryMap)

        case .atPosition(let c1, let i1, let pos):
            let template = theme.clueTemplates.atPosition.randomElement() ?? "{item1} at {pos}"
            let itemVal = getItemValue(c: c1, i: i1, map: categoryMap)
            // Naive ordinal conversion for demo; in production use NumberFormatter
            return template
                .replacingOccurrences(of: "{item1}", with: itemVal)
                .replacingOccurrences(of: "{pos}", with: "\(pos + 1)")
        }
    }

    private func applyTemplate(_ template: String, c1: String, i1: String, c2: String, i2: String, categoryMap: [String: PuzzleCategory]) -> String {
        let v1 = getItemValue(c: c1, i: i1, map: categoryMap)
        let v2 = getItemValue(c: c2, i: i2, map: categoryMap)

        return template
            .replacingOccurrences(of: "{item1}", with: v1)
            .replacingOccurrences(of: "{item2}", with: v2)
    }

    private func getItemValue(c: String, i: String, map: [String: PuzzleCategory]) -> String {
        guard let cat = map[c], let item = cat.items.first(where: { $0.id == i }) else {
            return "??"
        }
        return item.displayValue
    }
}
