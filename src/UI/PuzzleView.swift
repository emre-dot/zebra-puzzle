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

    init(difficulty: Difficulty, isDaily: Bool = false) {
        self.difficulty = difficulty
        self.isDaily = isDaily
        _isDailyChallenge = State(initialValue: isDaily)
    }

    var body: some View {
        VStack {
            if let puzzle = puzzle {
                // Game Board
                ScrollView {
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

                        Text(puzzle.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Divider()

                        // Logic Grid Renderer
                        if puzzle.categories.count >= 2 {
                            let c1 = puzzle.categories[0]
                            let c2 = puzzle.categories[1]
                            LogicGrid(rowItems: c2.items, colItems: c1.items, userState: $userState)
                                .padding(.vertical)
                        }

                        Divider()

                        Text("Clues")
                            .font(.headline)

                        // Scrollable Clues Section
                        ScrollView {
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
                        }
                        .frame(maxHeight: 200) // Constrain height to make it scrollable independently if needed, or let parent scroll handle it.
                        // Since parent is ScrollView, nested ScrollView might be tricky.
                        // The user said "ipuçları bölümünde scrollable olsun".
                        // If the grid is large, the clues are pushed down.
                        // Let's remove the nested ScrollView and rely on the main one,
                        // BUT formatting implies they might want a fixed area.
                        // I will keep main scroll for now as it's safer for varying content sizes.
                        // The explicit requirement usually implies "make sure I can see them all".
                    }
                    .padding()
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
                .sheet(isPresented: $showShop) {
                    ShopView()
                }
                .alert(isPresented: $showHint) {
                    Alert(title: Text("Hint"), message: Text(hintText), dismissButton: .default(Text("OK")))
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

    func loadAndGenerate() {
        // Load default theme (Classic)
        var url: URL?

        if let bundleUrl = Bundle.main.url(forResource: "en_classic", withExtension: "json") {
            url = bundleUrl
        } else {
            let path = "src/Data/Themes/en_classic.json"
            url = URL(fileURLWithPath: path)
        }

        guard let themeUrl = url else { return }

        do {
            try ThemeEngine.shared.loadTheme(from: themeUrl)
            if let loadedTheme = ThemeEngine.shared.getTheme(id: "en_classic") {
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
        hintText = HintSystem.shared.getHint(puzzle: p, userState: userState)
        showHint = true
        AnalyticsManager.shared.trackEvent(name: "hint_used", params: ["is_daily": isDailyChallenge])
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
                Color.clear.frame(width: 80, height: 80) // Increased height for vertical text
                ForEach(colItems) { item in
                    VStack {
                        Spacer()
                        Text(item.displayValue)
                            .font(.caption)
                            .lineLimit(1)
                            .fixedSize()
                            .rotationEffect(.degrees(-90))
                            .frame(width: 40)
                    }
                    .frame(width: 40, height: 80)
                    .border(Color.gray.opacity(0.2))
                }
            }

            // Rows
            ForEach(rowItems) { rItem in
                HStack(spacing: 0) {
                    Text(rItem.displayValue)
                        .font(.caption)
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
