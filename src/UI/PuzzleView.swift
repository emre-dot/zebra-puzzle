import SwiftUI

struct PuzzleView: View {
    let difficulty: Difficulty
    var isDaily: Bool = false

    @State private var puzzle: ZebraPuzzle?
    @State private var theme: ThemeDefinition?
    @State private var userState: [String: Bool] = [:] // Key: "id1_id2", Value: isMatched
    @State private var hintText: String = ""
    @State private var showHint: Bool = false
    @State private var showShop: Bool = false
    @State private var isDailyChallenge: Bool = false
    @State private var isGameComplete: Bool = false
    @State private var completionMessage: String = ""

    init(difficulty: Difficulty, isDaily: Bool = false) {
        self.difficulty = difficulty
        self.isDaily = isDaily
        _isDailyChallenge = State(initialValue: isDaily)
    }

    var body: some View {
        GeometryReader { geo in
            VStack {
                if let puzzle = puzzle {
                    // Calculate dynamic cell size based on screen width
                    let numItems = CGFloat(puzzle.categories.first?.items.count ?? 4)
                    let padding: CGFloat = 16
                    let spacing: CGFloat = 2
                    // Formula: (Screen - 2*padding - spacing*(N-1)) / N
                    // We use geo.size.width - 2*padding (for leading/trailing)
                    // Then divide by numItems.
                    // This assumes we want ONE block of items to fit the screen width, which is a good heuristic for usability.
                    let availableWidth = geo.size.width - (padding * 2)
                    let calculatedSize = (availableWidth - (spacing * (numItems - 1))) / numItems

                    // Clamp size to reasonable limits (e.g., max 50 to avoid huge cells on iPad, min 30)
                    let cellSize = max(30, min(calculatedSize, 60))

                    // Game Board
                    ScrollView([.vertical, .horizontal]) {
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Text(puzzle.themeTitle)
                                    .font(.title)
                                    .bold()
                                Spacer()
                                if isDailyChallenge {
                                    Text("DAILY")
                                        .font(.caption)
                                        .padding(4)
                                        .background(Color.orange)
                                        .foregroundColor(.white)
                                        .cornerRadius(4)
                                }
                            }
                            .padding(.top)
                            .padding(.horizontal) // Apply padding to text content

                            Text(puzzle.description)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)

                            Divider()
                                .padding(.horizontal)

                            // Logic Grid Renderer (Staircase Layout)
                            VStack(alignment: .leading, spacing: 10) {
                                ForEach(1..<puzzle.categories.count, id: \.self) { rowIdx in
                                    HStack(alignment: .top, spacing: 10) {
                                        ForEach(0..<rowIdx, id: \.self) { colIdx in
                                            let rowCat = puzzle.categories[rowIdx]
                                            let colCat = puzzle.categories[colIdx]

                                            VStack(spacing: 0) {
                                                LogicGrid(
                                                    rowItems: rowCat.items,
                                                    colItems: colCat.items,
                                                    userState: $userState,
                                                    showColHeaders: rowIdx == colIdx + 1,
                                                    showRowHeaders: colIdx == 0,
                                                    cellSize: cellSize
                                                )
                                            }
                                        }
                                    }
                                }
                            }
                            .padding() // Padding around the grid
                            .onChange(of: userState) { _ in
                                checkCompletion()
                            }

                            Divider()
                                .padding(.horizontal)

                            Text("Clues")
                                .font(.headline)
                                .padding(.horizontal)

                            // Clues Section
                            // No nested scroll, just list them.
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(puzzle.clues) { clue in
                                    HStack(alignment: .top) {
                                        Image(systemName: "circle.fill")
                                            .font(.system(size: 6))
                                            .padding(.top, 6)
                                        Text(clue.text)
                                            .font(.body)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 40)
                        }
                    }

                    // Bottom Bar
                    HStack {
                        if !isDailyChallenge {
                            Button(action: {
                                generatePuzzle()
                            }) {
                                Label("New", systemImage: "arrow.clockwise")
                            }
                        }

                        Spacer()

                        Button(action: {
                            showShop = true
                        }) {
                            Label("Shop", systemImage: "cart")
                        }

                        Spacer()

                        Button(action: {
                            requestHint()
                        }) {
                            Label("Hint", systemImage: "lightbulb")
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground)) // Ensure visibility over scroll content
                    .sheet(isPresented: $showShop) {
                        ShopView()
                    }
                    .alert(isPresented: $showHint) {
                        Alert(title: Text("Hint"), message: Text(hintText), dismissButton: .default(Text("OK")))
                    }
                    .alert(isPresented: $isGameComplete) {
                        Alert(title: Text("Puzzle Complete"), message: Text(completionMessage), dismissButton: .default(Text("OK"), action: {
                            // Optional: Navigate back or reset
                        }))
                    }

                } else {
                    // Loading / Init State
                    ProgressView("Generating Puzzle...")
                        .onAppear {
                            loadAndGenerate()
                        }
                }
            }
            .navigationTitle("Puzzle")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func loadAndGenerate() {
        // Load Selected Theme from Settings
        let themeId = AppThemeManager.shared.selectedThemeId
        var url: URL?

        if let bundleUrl = Bundle.main.url(forResource: themeId, withExtension: "json") {
            url = bundleUrl
        } else {
            // Fallback path
            let path = "src/Data/Themes/\(themeId).json"
            url = URL(fileURLWithPath: path)
        }

        guard let themeUrl = url else {
            print("Theme file not found: \(themeId)")
            return
        }

        do {
            try ThemeEngine.shared.loadTheme(from: themeUrl)
            if let loadedTheme = ThemeEngine.shared.getTheme(id: themeId) {
                self.theme = loadedTheme
                if isDailyChallenge {
                    startDailyChallenge(theme: loadedTheme)
                } else {
                    generatePuzzle(theme: loadedTheme)
                }
            }
        } catch {
            print("Failed to load theme: \(error)")
        }
    }

    func generatePuzzle(theme: ThemeDefinition? = nil) {
        guard let t = theme ?? self.theme else { return }
        self.puzzle = PuzzleGenerator.shared.generatePuzzle(difficulty: self.difficulty, theme: t)
        self.userState = [:]

        AnalyticsManager.shared.trackEvent(name: "puzzle_start", params: ["theme": t.id, "difficulty": difficulty.rawValue])
    }

    func startDailyChallenge(theme: ThemeDefinition) {
        let seed = DailyChallengeManager.shared.getDailySeed()
        self.puzzle = PuzzleGenerator.shared.generatePuzzle(difficulty: .hard, theme: theme, seed: seed)
        self.userState = [:]

        AnalyticsManager.shared.trackEvent(name: "daily_challenge_start", params: ["seed": seed])
    }

    func requestHint() {
        guard let p = self.puzzle else { return }

        if StoreManager.shared.isProMember {
            // Free hints for Pro
            showHint(for: p)
        } else {
            // Show Ad
            AdManager.shared.showRewardedAd { success in
                if success {
                    showHint(for: p)
                }
            }
        }
    }

    func showHint(for p: ZebraPuzzle) {
        let hintAction = HintSystem.shared.getHint(puzzle: p, userState: userState)
        hintText = hintAction.text

        if let cell = hintAction.cellToFill {
            // Apply the hint directly
            userState[cell.key] = cell.value
        }

        showHint = true
        AnalyticsManager.shared.trackEvent(name: "hint_used", params: ["is_daily": isDailyChallenge])
    }

    func checkCompletion() {
        guard let p = puzzle else { return }
        let categories = p.categories
        var isCorrect = true
        var filledCount = 0

        for cat1 in categories {
            for cat2 in categories {
                if cat1.id == cat2.id { continue }
                if cat1.id > cat2.id { continue }

                guard let sol1 = p.solution[cat1.id],
                      let sol2 = p.solution[cat2.id] else { continue }

                for i in 0..<sol1.count {
                    let item1 = sol1[i]
                    let item2 = sol2[i]
                    let trueKey = item1 < item2 ? "\(item1)_\(item2)" : "\(item2)_\(item1)"

                    if userState[trueKey] != true {
                        isCorrect = false
                    } else {
                        filledCount += 1
                    }
                }

                for item1 in cat1.items.map({$0.id}) {
                    for item2 in cat2.items.map({$0.id}) {
                        let key = item1 < item2 ? "\(item1)_\(item2)" : "\(item2)_\(item1)"

                        if let idx1 = sol1.firstIndex(of: item1),
                           let idx2 = sol2.firstIndex(of: item2) {
                            let shouldBeTrue = (idx1 == idx2)

                            if userState[key] == true && !shouldBeTrue {
                                isCorrect = false
                            }
                        }
                    }
                }
            }
        }

        let numCats = categories.count
        let numItems = categories.first?.items.count ?? 0
        let totalPairs = (numCats * (numCats - 1)) / 2
        let expectedTrue = totalPairs * numItems

        if filledCount == expectedTrue && isCorrect {
            completionMessage = "Congratulations! You solved the puzzle correctly."
            isGameComplete = true

            if isDailyChallenge {
                DailyChallengeManager.shared.markDailyChallengeCompleted()
                AnalyticsManager.shared.trackEvent(name: "daily_challenge_completed", params: [:])
            }
        }
    }
}

struct LogicGrid: View {
    let rowItems: [PuzzleItem]
    let colItems: [PuzzleItem]
    @Binding var userState: [String: Bool]
    var showColHeaders: Bool = true
    var showRowHeaders: Bool = true
    var cellSize: CGFloat // Dynamic cell size

    // Derived header size (can be slightly larger or same as cell)
    var headerSize: CGFloat {
        return max(cellSize * 1.5, 60)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Row
            if showColHeaders {
                HStack(spacing: 0) {
                    if showRowHeaders {
                        Color.clear.frame(width: headerSize, height: headerSize)
                    }
                    ForEach(colItems) { item in
                        VStack {
                            Spacer()
                            Text(item.displayValue)
                                .font(.system(size: 10)) // Use smaller font for headers
                                .lineLimit(1)
                                .fixedSize()
                                .rotationEffect(.degrees(-90))
                                .frame(width: cellSize)
                        }
                        .frame(width: cellSize, height: headerSize)
                        .border(Color.gray.opacity(0.2))
                    }
                }
            }

            // Rows
            ForEach(rowItems) { rItem in
                HStack(spacing: 0) {
                    if showRowHeaders {
                        Text(rItem.displayValue)
                            .font(.system(size: 10))
                            .frame(width: headerSize, height: cellSize, alignment: .trailing)
                            .padding(.trailing, 2)
                    }

                    ForEach(colItems) { cItem in
                        GridCell(rId: rItem.id, cId: cItem.id, userState: $userState, size: cellSize)
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
    let size: CGFloat

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
                        Circle().stroke(Color.green, lineWidth: 2).padding(size * 0.1)
                    } else {
                        Image(systemName: "xmark").foregroundColor(.red).font(.system(size: size * 0.5))
                    }
                }
            }
            .frame(width: size, height: size)
        }
    }
}
