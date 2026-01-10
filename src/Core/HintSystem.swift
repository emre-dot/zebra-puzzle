import Foundation

public struct HintAction {
    public let text: String
    public let cellToFill: (key: String, value: Bool)?
}

public class HintSystem {
    public static let shared = HintSystem()

    /// Analyzes the current grid state vs the solution and provides a hint.
    /// - Parameters:
    ///   - puzzle: The current active puzzle.
    ///   - userState: A map of (RowID, ColID) -> CellState (True/False/Unknown).
    /// - Returns: A string describing a hint.
    public func getHint(puzzle: ZebraPuzzle, userState: [String: Bool]) -> HintAction {
        // userState key format: "itemId1_itemId2" (sorted or canonical order)

        // Strategy: Find a TRUE relationship in the solution that the user has not marked as TRUE yet.

        let categories = puzzle.categories
        for cat1 in categories {
            for cat2 in categories {
                if cat1.id == cat2.id { continue }

                // Check true pairings in solution
                guard let sol1 = puzzle.solution[cat1.id],
                      let sol2 = puzzle.solution[cat2.id] else { continue }

                for i in 0..<sol1.count {
                    let item1 = sol1[i] // e.g., "red"
                    let item2 = sol2[i] // e.g., "brit"

                    // Construct key
                    let key = makeKey(item1, item2)
                    let isMarked = userState[key] ?? false

                    if !isMarked {
                        // Found a missing link!
                        // In a real logic engine, we would check if this is DEDUCIBLE.
                        // For this version, we act as a "Magic Hint" that reveals a correct cell.

                        // We need the display names for the hint text
                        let name1 = getDisplayName(id: item1, in: cat1)
                        let name2 = getDisplayName(id: item2, in: cat2)

                        return HintAction(
                            text: "Hint: \(name1) is matched with \(name2).",
                            cellToFill: (key: key, value: true)
                        )
                    }
                }
            }
        }

        return HintAction(text: "You seem to have solved everything!", cellToFill: nil)
    }

    private func makeKey(_ id1: String, _ id2: String) -> String {
        return id1 < id2 ? "\(id1)_\(id2)" : "\(id2)_\(id1)"
    }

    private func getDisplayName(id: String, in category: PuzzleCategory) -> String {
        return category.items.first(where: { $0.id == id })?.displayValue ?? id
    }
}
