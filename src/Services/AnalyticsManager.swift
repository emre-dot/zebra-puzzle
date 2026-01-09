import Foundation

// MARK: - AnalyticsManager (Mock)

/// Handles event tracking for user behavior analysis.
public class AnalyticsManager {
    public static let shared = AnalyticsManager()

    private init() {}

    public func trackEvent(name: String, params: [String: Any]) {
        // In a real app, this sends data to Firebase / Mixpanel
        print("📊 [Analytics] Event: \(name), Params: \(params)")
    }
}
