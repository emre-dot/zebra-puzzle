import Foundation

enum CellState: Equatable {
    case unknown
    case yes // The user has marked this as "True" (Green O)
    case no  // The user has marked this as "False" (Red X)
}

struct GridPosition: Hashable {
    let rowItemId: String
    let colItemId: String
}

class PuzzleLogicEngine: ObservableObject {
    @Published var gridState: [GridPosition: CellState] = [:]
    let puzzle: ZebraPuzzle

    init(puzzle: ZebraPuzzle) {
        self.puzzle = puzzle
    }

    // MARK: - User Interaction

    func toggleState(at position: GridPosition) {
        let currentState = gridState[position] ?? .unknown

        switch currentState {
        case .unknown:
            gridState[position] = .yes
            // If user marks YES, auto-fill NO for other cells in same row/col for this category pair
            autoFillNegatives(for: position)
        case .yes:
            gridState[position] = .no
        case .no:
            gridState[position] = .unknown
        }

        checkForCompletion()
    }

    private func autoFillNegatives(for position: GridPosition) {
        // Logic: If Item A is confirmed to be paired with Item B,
        // then Item A cannot be with Item C, D, etc.
        // And Item E, F cannot be with Item B.

        // Find which categories these items belong to
        guard let rowCat = category(for: position.rowItemId),
              let colCat = category(for: position.colItemId) else { return }

        // Mark all other items in rowCat as NO for this colItemId
        for item in rowCat.items {
            if item.id != position.rowItemId {
                let pos = GridPosition(rowItemId: item.id, colItemId: position.colItemId)
                if gridState[pos] != .yes { // Don't overwrite existing Yes (though that would be a conflict)
                    gridState[pos] = .no
                }
            }
        }

        // Mark all other items in colCat as NO for this rowItemId
        for item in colCat.items {
            if item.id != position.colItemId {
                let pos = GridPosition(rowItemId: position.rowItemId, colItemId: item.id)
                if gridState[pos] != .yes {
                    gridState[pos] = .no
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func category(for itemId: String) -> PuzzleCategory? {
        return puzzle.categories.first { category in
            category.items.contains { $0.id == itemId }
        }
    }

    // MARK: - Validation

    func checkConflicts() -> [String] {
        var conflicts: [String] = []

        // 1. Check for immediate contradictions (e.g., two YES in same row/category block)
        // Implementation omitted for brevity in this sample, but would iterate the gridState.

        return conflicts
    }

    func checkForCompletion() {
        // Check if the current gridState matches the puzzle.solution
        // This is complex because the solution is typically given as "House 1, House 2, House 3"
        // but the grid is pairwise relationships (Item A vs Item B).

        // To verify, we need to infer the full solution from the pairwise relationships.
        // Or, simpler for this level: Just check if we have enough YES marks consistent with the solution.

        print("Checking for completion... (Logic implementation placeholder)")
    }

    /// Verifies if a specific user marking is correct according to the solution
    func isMoveCorrect(at position: GridPosition, state: CellState) -> Bool {
        // Retrieve the house index for the row item and col item from the solution
        // If they share the same index, the relationship is True. Otherwise False.

        guard let rowCat = category(for: position.rowItemId),
              let colCat = category(for: position.colItemId),
              let rowSolution = puzzle.solution[rowCat.id],
              let colSolution = puzzle.solution[colCat.id] else {
            return false
        }

        guard let rowIndex = rowSolution.firstIndex(of: position.rowItemId),
              let colIndex = colSolution.firstIndex(of: position.colItemId) else {
            return false
        }

        let shouldBeYes = (rowIndex == colIndex)

        if state == .yes {
            return shouldBeYes
        } else if state == .no {
            return !shouldBeYes
        }

        return true // Unknown is neutral
    }
}
