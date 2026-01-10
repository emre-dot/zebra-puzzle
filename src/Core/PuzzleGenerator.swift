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
        // Ensure we don't crash if theme has fewer categories than requested, though we updated themes.
        let availableKeys = theme.categoryData.keys.sorted()
        let safeNumCats = min(numCats, availableKeys.count)

        let selectedCategoryKeys = Array(availableKeys.prefix(safeNumCats))
        var categories: [PuzzleCategory] = []
        var categoryIds: [CategoryID] = []

        for key in selectedCategoryKeys {
            guard let data = theme.categoryData[key] else { continue }
            // Take first N items
            let safeNumItems = min(numItems, data.items.count)
            let items = data.items.prefix(safeNumItems).map {
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
        case .easy: return (4, 4)   // User: 4 cats, 4 items
        case .medium: return (5, 5) // User: 5 cats, 5 items
        case .hard: return (6, 6)   // User: 6 cats, 6 items
        }
    }

    private func generateRules(solution: [CategoryID: [ItemID]], categories: [PuzzleCategory], difficulty: Difficulty, rng: inout AnyRandomNumberGenerator) -> [PuzzleRule] {
        var rules: [PuzzleRule] = []
        let numItems = solution.values.first?.count ?? 0
        let catIds = categories.map { $0.id }

        // Target clue counts
        let targetClues: Int
        switch difficulty {
        case .easy: targetClues = Int.random(in: 9...12, using: &rng)
        case .medium: targetClues = Int.random(in: 14...18, using: &rng)
        case .hard: targetClues = Int.random(in: 20...26, using: &rng)
        }

        // Weights for random clue generation (approximate probabilities)
        let wDirect: Double // isSame
        let wNext: Double   // nextTo
        let wLeft: Double   // leftOf
        let wPos: Double    // atPosition

        switch difficulty {
        case .easy:
            wDirect = 0.6
            wNext = 0.3
            wLeft = 0.0
            wPos = 0.1
        case .medium:
            wDirect = 0.4
            wNext = 0.4
            wLeft = 0.1
            wPos = 0.1
        case .hard:
            wDirect = 0.2
            wNext = 0.4
            wLeft = 0.3
            wPos = 0.1
        }

        // 1. Initial Set: Ensure solvability by providing a backbone (Position + Direct + NextTo)
        // Always provide at least one absolute position
        if let firstCat = catIds.first, let items = solution[firstCat] {
            let pos = Int.random(in: 0..<numItems, using: &rng)
            let item = items[pos]
            rules.append(.atPosition(firstCat, item, pos + 1)) // 1-based index usually
        }

        // Fill remaining clues until target is reached
        // We generate valid facts from the solution
        var attempts = 0
        while rules.count < targetClues && attempts < 1000 {
            attempts += 1

            // Pick a rule type based on weights
            let r = Double.random(in: 0...1, using: &rng)

            if r < wDirect {
                // Generate isSame
                let c1 = catIds.randomElement(using: &rng)!
                var c2 = catIds.randomElement(using: &rng)!
                while c1 == c2 { c2 = catIds.randomElement(using: &rng)! }

                let idx = Int.random(in: 0..<numItems, using: &rng)
                let item1 = solution[c1]![idx]
                let item2 = solution[c2]![idx]

                let rule = PuzzleRule.isSame(c1, item1, c2, item2)
                if !rules.contains(rule) { rules.append(rule) }

            } else if r < wDirect + wNext {
                // Generate nextTo (idx and idx+1)
                let idx = Int.random(in: 0..<(numItems - 1), using: &rng)
                let c1 = catIds.randomElement(using: &rng)!
                let c2 = catIds.randomElement(using: &rng)!

                let item1 = solution[c1]![idx]
                let item2 = solution[c2]![idx + 1]

                let rule = PuzzleRule.nextTo(c1, item1, c2, item2)
                if !rules.contains(rule) { rules.append(rule) }

            } else if r < wDirect + wNext + wLeft {
                // Generate leftOf (idx1 < idx2)
                let idx1 = Int.random(in: 0..<(numItems - 1), using: &rng)
                let idx2 = Int.random(in: (idx1 + 1)..<numItems, using: &rng)

                let c1 = catIds.randomElement(using: &rng)!
                let c2 = catIds.randomElement(using: &rng)!

                let item1 = solution[c1]![idx1]
                let item2 = solution[c2]![idx2]

                let rule = PuzzleRule.leftOf(c1, item1, c2, item2)
                if !rules.contains(rule) { rules.append(rule) }

            } else {
                // Generate atPosition
                let idx = Int.random(in: 0..<numItems, using: &rng)
                let c1 = catIds.randomElement(using: &rng)!
                let item = solution[c1]![idx]

                let rule = PuzzleRule.atPosition(c1, item, idx + 1) // 1-based
                if !rules.contains(rule) { rules.append(rule) }
            }
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
