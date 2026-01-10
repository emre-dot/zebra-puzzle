import SwiftUI

struct LandingView: View {
    @State private var showPuzzle = false
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var showShop = false
    @State private var isDaily = false

    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Title
                VStack(spacing: 10) {
                    Image(systemName: "checkerboard.rectangle")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.blue)

                    Text("Zebra Puzzle Pro")
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    Text("Train your brain, one clue at a time.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 50)

                Spacer()

                // Difficulty Selection
                VStack(spacing: 15) {
                    Text("New Game")
                        .font(.headline)
                        .foregroundColor(.gray)

                    DifficultyButton(title: "Easy", color: .green) {
                        startGame(difficulty: .easy)
                    }

                    DifficultyButton(title: "Medium", color: .orange) {
                        startGame(difficulty: .medium)
                    }

                    DifficultyButton(title: "Hard", color: .red) {
                        startGame(difficulty: .hard)
                    }
                }

                // Daily Challenge
                Button(action: {
                    startDaily()
                }) {
                    HStack {
                        Image(systemName: "flame.fill")
                        Text("Daily Challenge")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 40)

                Spacer()

                // Shop Button
                Button(action: {
                    showShop = true
                }) {
                    Label("Theme Shop", systemImage: "cart")
                }
                .padding(.bottom, 20)

                // Navigation Link (Hidden)
                NavigationLink(destination: PuzzleView(difficulty: selectedDifficulty, isDaily: isDaily), isActive: $showPuzzle) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showShop) {
                ShopView()
            }
        }
    }

    private func startGame(difficulty: Difficulty) {
        self.selectedDifficulty = difficulty
        self.isDaily = false
        self.showPuzzle = true
    }

    private func startDaily() {
        self.selectedDifficulty = .hard // Daily is usually hard
        self.isDaily = true
        self.showPuzzle = true
    }
}

struct DifficultyButton: View {
    let title: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(color.opacity(0.15))
                .foregroundColor(color)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: 2)
                )
        }
        .padding(.horizontal, 40)
    }
}
