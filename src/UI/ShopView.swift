import SwiftUI

struct ShopView: View {
    @ObservedObject var store = StoreManager.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Pro Membership")) {
                    HStack {
                        Image(systemName: "crown.fill")
                            .foregroundColor(.yellow)
                        VStack(alignment: .leading) {
                            Text("Zebra Puzzle Pro")
                                .font(.headline)
                            Text("No Ads • Infinite Hints • All Themes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        if store.isProMember {
                            Text("Active")
                                .foregroundColor(.green)
                        } else {
                            Button("$2.99/mo") {
                                Task { await store.purchasePro() }
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section(header: Text("Theme Packs")) {
                    ThemeRow(id: "en_classic", name: "English Classic", price: "Free")
                    ThemeRow(id: "tr_local", name: "Turkish Local", price: "Free")
                    ThemeRow(id: "jp_anime", name: "Japanese Anime", price: "$1.99")
                    ThemeRow(id: "us_scifi", name: "Sci-Fi Future", price: "$1.99")
                }
            }
            .navigationTitle("Shop")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") { presentationMode.wrappedValue.dismiss() }
                }
            }
        }
    }
}

struct ThemeRow: View {
    let id: String
    let name: String
    let price: String
    @ObservedObject var store = StoreManager.shared

    var isUnlocked: Bool {
        store.isThemeUnlocked(id: id)
    }

    var body: some View {
        HStack {
            Image(systemName: "paintpalette") // Placeholder icon
            Text(name)
            Spacer()
            if isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Button(price) {
                    Task { await store.purchaseTheme(id: id) }
                }
                .buttonStyle(.bordered)
            }
        }
    }
}
