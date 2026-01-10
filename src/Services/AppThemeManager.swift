import SwiftUI

public class AppThemeManager: ObservableObject {
    public static let shared = AppThemeManager()

    @AppStorage("isDarkMode") public var isDarkMode: Bool = false
    @AppStorage("selectedThemeId") public var selectedThemeId: String = "en_classic"

    private init() {}
}
