import Foundation

// MARK: - AdManager (Mock)

/// Handles AdMob / Rewarded Video logic.
public class AdManager: ObservableObject {
    public static let shared = AdManager()

    @Published public var isAdReady: Bool = true

    private init() {}

    /// Shows a rewarded video ad.
    /// - Parameter completion: Called with `true` if user watched the whole ad.
    public func showRewardedAd(completion: @escaping (Bool) -> Void) {
        guard isAdReady else {
            completion(false)
            return
        }

        print("[AdManager] Showing Rewarded Video...")

        // Mock Ad Display Duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            print("[AdManager] Ad Completed!")
            AnalyticsManager.shared.trackEvent(name: "ad_watched", params: ["type": "rewarded"])
            completion(true)
        }
    }
}
