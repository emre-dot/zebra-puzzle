import SwiftUI

struct PuzzleView: View {
    let puzzle: ZebraPuzzle
    @StateObject private var logicEngine: PuzzleLogicEngine

    init(puzzle: ZebraPuzzle) {
        self.puzzle = puzzle
        _logicEngine = StateObject(wrappedValue: PuzzleLogicEngine(puzzle: puzzle))
    }

    var body: some View {
        VStack {
            // Header
            Text(puzzle.context.title)
                .font(.largeTitle)
                .padding()

            Text(puzzle.context.description)
                .font(.body)
                .padding(.bottom)

            // Scrollable Content
            ScrollView {
                VStack(spacing: 20) {
                    // The Logic Grid
                    PuzzleGridView(puzzle: puzzle, logicEngine: logicEngine)
                        .padding()

                    // The Clues
                    ClueListView(clues: puzzle.clues)
                        .padding()
                }
            }
        }
    }
}

struct PuzzleGridView: View {
    let puzzle: ZebraPuzzle
    @ObservedObject var logicEngine: PuzzleLogicEngine

    // We need to determine which categories to plot against which.
    // Standard Zebra grid: Category 1 on X axis, Categories 2..N on Y axis (stacked).
    // For simplicity in this mock, let's just show Cat 1 vs Cat 2.

    var body: some View {
        VStack {
            Text("Logic Grid (Preview)")
                .font(.headline)

            // This is a simplified grid renderer.
            // In a real app, this would dynamically generate the triangular/rectangular logic grid structure.
            if puzzle.categories.count >= 2 {
                let catX = puzzle.categories[0]
                let catY = puzzle.categories[1]

                GridStack(rows: catY.items.count, columns: catX.items.count) { row, col in
                    let rowItem = catY.items[row]
                    let colItem = catX.items[col]
                    let pos = GridPosition(rowItemId: rowItem.id, colItemId: colItem.id)
                    let state = logicEngine.gridState[pos] ?? .unknown

                    CellView(state: state) {
                        logicEngine.toggleState(at: pos)
                    }
                }
            }
        }
        .border(Color.gray, width: 1)
    }
}

struct CellView: View {
    let state: CellState
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .border(Color.black.opacity(0.2), width: 1)

                switch state {
                case .yes:
                    Circle()
                        .stroke(Color.green, lineWidth: 3)
                        .padding(4)
                case .no:
                    Image(systemName: "xmark")
                        .foregroundColor(.red)
                case .unknown:
                    EmptyView()
                }
            }
        }
        .frame(width: 40, height: 40)
    }
}

struct GridStack<Content: View>: View {
    let rows: Int
    let columns: Int
    let content: (Int, Int) -> Content

    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< rows, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0 ..< columns, id: \.self) { column in
                        content(row, column)
                    }
                }
            }
        }
    }
}

struct ClueListView: View {
    let clues: [PuzzleClue]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Clues")
                .font(.headline)

            ForEach(clues) { clue in
                HStack(alignment: .top) {
                    Image(systemName: "info.circle")
                    Text(clue.text)
                }
                .padding(5)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(5)
            }
        }
    }
}
