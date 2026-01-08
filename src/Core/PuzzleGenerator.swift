import Foundation

public class PuzzleGenerator {
    public static let shared = PuzzleGenerator()

    public init() {}

    public func generatePuzzle(difficulty: Difficulty, theme: ThemeDefinition) -> ZebraPuzzle {
        // 1. Determine Grid Size based on Difficulty (Mock)
        // Easy: 3 Categories, 3 Items
        // Medium: 4 Categories, 4 Items (Standard)
        // Hard: 5 Categories, 5 Items
        let (numCats, numItems) = getDimensions(for: difficulty)

        // 2. Select Categories from Theme
        let selectedCategoryKeys = Array(theme.categoryData.keys.prefix(numCats))
        var categories: [PuzzleCategory] = []
        var categoryIds: [CategoryID] = []

        for key in selectedCategoryKeys {
            guard let data = theme.categoryData[key] else { continue }
            // Take first N items
            let items = data.items.prefix(numItems).map {
                PuzzleItem(id: $0.id, displayValue: $0.name, iconName: $0.icon)
            }
            let category = PuzzleCategory(id: key, name: data.name, items: Array(items))
            categories.append(category)
            categoryIds.append(key)
        }

        // 3. Generate Solution Grid
        // Map: CategoryID -> [ItemID] (ordered by house 0..N)
        var solution: [CategoryID: [ItemID]] = [:]

        // First category is "Anchor" (e.g. Houses 1,2,3,4) - usually implies position.
        // For standard Zebra, all categories are permuted relative to positions.
        // Let's just shuffle items for each category.
        for cat in categories {
            var items = cat.items.map { $0.id }
            items.shuffle()
            solution[cat.id] = items
        }

        // 4. Generate Rules (Logic) derived from Solution
        let rules = generateRules(solution: solution, categories: categories, difficulty: difficulty)

        // 5. Convert Rules to Text Clues
        let categoryMap = Dictionary(uniqueKeysWithValues: categories.map { ($0.id, $0) })
        var clues: [PuzzleClue] = []

        for (index, rule) in rules.enumerated() {
            let text = ThemeEngine.shared.generateClueText(rule: rule, theme: theme, categoryMap: categoryMap)
            clues.append(PuzzleClue(id: "clue_\(index)", text: text, rule: rule))
        }

        return ZebraPuzzle(
            id: UUID().uuidString,
            difficulty: difficulty,
            themeTitle: theme.title,
            description: theme.description,
            categories: categories,
            clues: clues,
            solution: solution
        )
    }

    // MARK: - Helper Methods

    private func getDimensions(for difficulty: Difficulty) -> (Int, Int) {
        switch difficulty {
        case .easy: return (3, 3)
        case .medium: return (4, 4)
        case .hard: return (4, 5) // or 5x5 if theme allows
        }
    }

    private func generateRules(solution: [CategoryID: [ItemID]], categories: [PuzzleCategory], difficulty: Difficulty) -> [PuzzleRule] {
        var rules: [PuzzleRule] = []
        let numItems = solution.values.first?.count ?? 0
        let catIds = categories.map { $0.id }

        // A simple generator strategy:
        // Iterate through columns (houses) and generate "IsSame" facts.
        // Iterate through adjacencies and generate "NextTo" facts.

        // 1. Position Clue (Anchor)
        // e.g. "Item A is in the first house"
        if let firstCat = catIds.first, let items = solution[firstCat] {
            let item = items[0]
            rules.append(.atPosition(firstCat, item, 0))
        }

        // 2. Direct Links (Vertical)
        // "The Brit eats Bagels"
        // Randomly pick pairs from same column
        for i in 0..<numItems {
            // Pick two random categories
            let c1 = catIds.randomElement()!
            var c2 = catIds.randomElement()!
            while c1 == c2 { c2 = catIds.randomElement()! }

            let item1 = solution[c1]![i]
            let item2 = solution[c2]![i]

            rules.append(.isSame(c1, item1, c2, item2))
        }

        // 3. Adjacency (Horizontal)
        // "The Green house is next to the White house"
        for i in 0..<(numItems - 1) {
            let c1 = catIds.randomElement()!
            let c2 = catIds.randomElement()!
            // Can be same category for next to (Green next to White) or diff (Brit next to Dog)

            let item1 = solution[c1]![i]
            let item2 = solution[c2]![i+1]

            rules.append(.nextTo(c1, item1, c2, item2))
        }

        // Shuffle rules
        rules.shuffle()

        return rules
    }
}
