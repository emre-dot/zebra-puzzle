import Foundation

public class PuzzleGenerator {
    public static let shared = PuzzleGenerator()

    public init() {}

    /// Generates a puzzle. If `seed` is provided, the result is deterministic.
    public func generatePuzzle(difficulty: Difficulty, theme: ThemeDefinition, seed: Int? = nil) -> ZebraPuzzle {
        // Initialize RNG
        var rng: AnyRandomNumberGenerator
        if let s = seed {
            rng = AnyRandomNumberGenerator(LinearCongruentialGenerator(seed: UInt64(s)))
        } else {
            rng = AnyRandomNumberGenerator(SystemRandomNumberGenerator())
        }

        // 1. Determine Grid Size based on Difficulty
        let (numCats, numItems) = getDimensions(for: difficulty)

        // 2. Select Categories from Theme
        let selectedCategoryKeys = Array(theme.categoryData.keys.sorted().prefix(numCats)) // Sorted for determinism
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

        for cat in categories {
            var items = cat.items.map { $0.id }
            // Shuffle deterministically
            items.shuffle(using: &rng)
            solution[cat.id] = items
        }

        // 4. Generate Rules (Logic) derived from Solution
        let rules = generateRules(solution: solution, categories: categories, difficulty: difficulty, rng: &rng)

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

    private func generateRules(solution: [CategoryID: [ItemID]], categories: [PuzzleCategory], difficulty: Difficulty, rng: inout AnyRandomNumberGenerator) -> [PuzzleRule] {
        var rules: [PuzzleRule] = []
        let numItems = solution.values.first?.count ?? 0
        let catIds = categories.map { $0.id }

        // 1. Position Clue (Anchor)
        if let firstCat = catIds.first, let items = solution[firstCat] {
            let item = items[0]
            rules.append(.atPosition(firstCat, item, 0))
        }

        // 2. Direct Links (Vertical)
        for i in 0..<numItems {
            let c1 = catIds.randomElement(using: &rng)!
            var c2 = catIds.randomElement(using: &rng)!
            while c1 == c2 { c2 = catIds.randomElement(using: &rng)! }

            let item1 = solution[c1]![i]
            let item2 = solution[c2]![i]

            rules.append(.isSame(c1, item1, c2, item2))
        }

        // 3. Adjacency (Horizontal)
        for i in 0..<(numItems - 1) {
            let c1 = catIds.randomElement(using: &rng)!
            let c2 = catIds.randomElement(using: &rng)!

            let item1 = solution[c1]![i]
            let item2 = solution[c2]![i+1]

            rules.append(.nextTo(c1, item1, c2, item2))
        }

        rules.shuffle(using: &rng)

        return rules
    }
}

// MARK: - RNG Helpers

// Simple LCG for deterministic seed support
struct LinearCongruentialGenerator: RandomNumberGenerator {
    var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state = 6364136223846793005 &* state &+ 1442695040888963407
        return state
    }
}

// Type eraser for RNG
struct AnyRandomNumberGenerator: RandomNumberGenerator {
    var _next: () -> UInt64

    init<G: RandomNumberGenerator>(_ rng: G) {
        var rng = rng
        self._next = { rng.next() }
    }

    mutating func next() -> UInt64 {
        return _next()
    }
}
