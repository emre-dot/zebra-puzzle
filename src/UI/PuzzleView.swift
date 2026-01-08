import SwiftUI

struct PuzzleView: View {
    @State private var puzzle: ZebraPuzzle?
    @State private var theme: ThemeDefinition?
    @State private var userState: [String: Bool] = [:] // Key: "id1_id2", Value: isMatched
    @State private var hintText: String = ""
    @State private var showHint: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                if let puzzle = puzzle {
                    // Game Board
                    ScrollView {
                        VStack(alignment: .leading) {
                            Text(puzzle.themeTitle)
                                .font(.largeTitle)
                                .bold()

                            Text(puzzle.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Divider()

                            // Simple Grid Renderer
                            // We only show Cat 0 vs Cat 1 for brevity in this UI mock
                            if puzzle.categories.count >= 2 {
                                let c1 = puzzle.categories[0]
                                let c2 = puzzle.categories[1]
                                LogicGrid(rowItems: c2.items, colItems: c1.items, userState: $userState)
                            }

                            Divider()

                            Text("Clues")
                                .font(.headline)
                                .padding(.top)

                            ForEach(puzzle.clues) { clue in
                                Text("• " + clue.text)
                                    .padding(.vertical, 2)
                            }
                        }
                        .padding()
                    }

                    // Bottom Bar
                    HStack {
                        Button(action: {
                            generatePuzzle()
                        }) {
                            Label("New Puzzle", systemImage: "arrow.clockwise")
                        }

                        Spacer()

                        Button(action: {
                            if let p = self.puzzle {
                                hintText = HintSystem.shared.getHint(puzzle: p, userState: userState)
                                showHint = true
                            }
                        }) {
                            Label("Hint", systemImage: "lightbulb")
                        }
                    }
                    .padding()
                    .alert(isPresented: $showHint) {
                        Alert(title: Text("Hint"), message: Text(hintText), dismissButton: .default(Text("OK")))
                    }

                } else {
                    // Loading / Init State
                    Text("Loading Theme...")
                        .onAppear {
                            loadAndGenerate()
                        }
                }
            }
            .navigationTitle("Zebra Puzzle Pro")
        }
    }

    func loadAndGenerate() {
        // 1. Load Theme (Mock: Load local file)
        // In real app, this comes from bundle
        // We simulate loading the English Classic theme

        // We will create a mock ThemeDefinition manually here or try to load file if environment allowed.
        // Since we are in sandbox, let's use the file we wrote to src/Data/Themes/en_classic.json

        let path = "src/Data/Themes/en_classic.json" // Relative path
        let url = URL(fileURLWithPath: path)

        do {
            try ThemeEngine.shared.loadTheme(from: url)
            if let loadedTheme = ThemeEngine.shared.getTheme(id: "en_classic") {
                self.theme = loadedTheme
                generatePuzzle()
            }
        } catch {
            print("Failed to load theme: \(error)")
        }
    }

    func generatePuzzle() {
        guard let t = theme else { return }
        self.puzzle = PuzzleGenerator.shared.generatePuzzle(difficulty: .medium, theme: t)
        self.userState = [:] // Reset state
    }
}

struct LogicGrid: View {
    let rowItems: [PuzzleItem]
    let colItems: [PuzzleItem]
    @Binding var userState: [String: Bool]

    var body: some View {
        VStack(spacing: 0) {
            // Header Row
            HStack(spacing: 0) {
                Color.clear.frame(width: 80, height: 40)
                ForEach(colItems) { item in
                    Text(item.displayValue.prefix(3))
                        .frame(width: 40, height: 40)
                        .border(Color.gray.opacity(0.2))
                }
            }

            // Rows
            ForEach(rowItems) { rItem in
                HStack(spacing: 0) {
                    Text(rItem.displayValue)
                        .frame(width: 80, height: 40, alignment: .trailing)
                        .padding(.trailing, 5)

                    ForEach(colItems) { cItem in
                        GridCell(rId: rItem.id, cId: cItem.id, userState: $userState)
                    }
                }
            }
        }
    }
}

struct GridCell: View {
    let rId: String
    let cId: String
    @Binding var userState: [String: Bool]

    var key: String {
        rId < cId ? "\(rId)_\(cId)" : "\(cId)_\(rId)"
    }

    var body: some View {
        Button(action: {
            let current = userState[key]
            if current == true {
                userState[key] = false // false means "X" (No)
            } else if current == false {
                userState[key] = nil // nil means Empty
            } else {
                userState[key] = true // true means "O" (Yes)
            }
        }) {
            ZStack {
                Rectangle()
                    .stroke(Color.gray.opacity(0.3))
                    .background(Color.white)

                if let val = userState[key] {
                    if val {
                        Circle().stroke(Color.green, lineWidth: 2).padding(5)
                    } else {
                        Image(systemName: "xmark").foregroundColor(.red)
                    }
                }
            }
            .frame(width: 40, height: 40)
        }
    }
}
