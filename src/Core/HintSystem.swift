import Foundation

public class HintSystem {
    public static let shared = HintSystem()

    /// Analyzes the current grid state vs the solution and provides a hint.
    /// - Parameters:
    ///   - puzzle: The current active puzzle.
    ///   - userState: A map of (RowID, ColID) -> CellState (True/False/Unknown).
    /// - Returns: A string describing a hint.
    public func getHint(puzzle: ZebraPuzzle, userState: [String: Bool]) -> String {
        // userState key format: "itemId1_itemId2" (sorted or canonical order)

        // 1. Look for a "NextTo" clue that hasn't been satisfied.
        // This requires a complex solver state.
        // For this mock, we will simply cheat: Look for a relationship in the Solution that the user hasn't marked YES yet.

        let categories = puzzle.categories
        for cat1 in categories {
            for cat2 in categories {
                if cat1.id == cat2.id { continue }

                // Check true pairings in solution
                guard let sol1 = puzzle.solution[cat1.id],
                      let sol2 = puzzle.solution[cat2.id] else { continue }

                for i in 0..<sol1.count {
                    let item1 = sol1[i]
                    let item2 = sol2[i]

                    // Check if user has marked this
                    // Construct key
                    let key = makeKey(item1, item2)
                    let isMarked = userState[key] ?? false // Default false implies Unknown or No

                    if !isMarked {
                        return "Try to find the connection between \(item1) and \(item2). Look closely at clues regarding them."
                    }
                }
            }
        }

        return "You seem to be doing great! Re-read the clues."
    }

    private func makeKey(_ id1: String, _ id2: String) -> String {
        return id1 < id2 ? "\(id1)_\(id2)" : "\(id2)_\(id1)"
    }
}
