import Foundation

/// Manages the "Daily Challenge" logic.
/// Generates a seed based on the current date (YYYYMMDD), ensuring all users get the same puzzle.
public class DailyChallengeManager {
    public static let shared = DailyChallengeManager()

    private init() {}

    /// Returns the seed for today's daily challenge.
    public func getDailySeed() -> Int {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        let dateString = formatter.string(from: Date())
        return Int(dateString) ?? 0
    }

    /// Checks if the user has already completed the daily challenge (Mock).
    public func isDailyChallengeCompleted() -> Bool {
        // In a real app, check Persistence Layer/UserDefaults
        return UserDefaults.standard.bool(forKey: "daily_completed_\(getDailySeed())")
    }

    /// Marks the daily challenge as completed.
    public func markDailyChallengeCompleted() {
        UserDefaults.standard.set(true, forKey: "daily_completed_\(getDailySeed())")
    }
}
