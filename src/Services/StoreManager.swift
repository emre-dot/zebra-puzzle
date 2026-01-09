import Foundation

// MARK: - StoreManager (Mock)

/// Handles In-App Purchases (IAP) using StoreKit 2 concepts.
/// Mocks the purchasing process for themes and subscriptions.
public class StoreManager: ObservableObject {
    public static let shared = StoreManager()

    @Published public var unlockedThemes: Set<String> = ["en_classic", "tr_local"] // Default unlocked
    @Published public var isProMember: Bool = false

    private init() {
        // Load from UserDefaults
        let savedThemes = UserDefaults.standard.array(forKey: "unlockedThemes") as? [String] ?? []
        for t in savedThemes { unlockedThemes.insert(t) }

        isProMember = UserDefaults.standard.bool(forKey: "isProMember")
    }

    /// Purchases a specific theme.
    public func purchaseTheme(id: String) async -> Bool {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Mock Success
        unlockedThemes.insert(id)
        saveState()
        AnalyticsManager.shared.trackEvent(name: "purchase_success", params: ["item": id])
        return true
    }

    /// Purchases the Pro Subscription.
    public func purchasePro() async -> Bool {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        isProMember = true
        saveState()
        AnalyticsManager.shared.trackEvent(name: "subscribe_success", params: [:])
        return true
    }

    public func isThemeUnlocked(id: String) -> Bool {
        return unlockedThemes.contains(id) || isProMember
    }

    private func saveState() {
        UserDefaults.standard.set(Array(unlockedThemes), forKey: "unlockedThemes")
        UserDefaults.standard.set(isProMember, forKey: "isProMember")
    }
}
