import Foundation
import Combine

class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    @Published var currentLanguageCode: String = "en-US"

    private init() {
        // Load saved language or default to system language
        self.currentLanguageCode = Locale.current.identifier
    }

    func setLanguage(code: String) {
        self.currentLanguageCode = code
        // Trigger reload of UI strings and Puzzle content
    }

    /// Loads a puzzle and adapts it to the current cultural context
    func loadCulturalizedPuzzle(puzzleId: String) -> ZebraPuzzle? {
        // 1. Fetch the generic logic skeleton for the puzzle ID
        // 2. Fetch the 'Cultural Dictionary' for the currentLanguageCode
        // 3. Merge them to produce the final ZebraPuzzle struct

        // This is a simplified mock implementation
        let languagePrefix = String(currentLanguageCode.prefix(2))
        let language: String
        switch languagePrefix {
        case "tr": language = "tr"
        case "ja": language = "ja"
        default: language = "en"
        }

        let filename = "sample_puzzle_\(language)"

        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            print("Failed to load puzzle file: \(filename).json")
            return nil
        }

        do {
            let decoder = JSONDecoder()
            let puzzle = try decoder.decode(ZebraPuzzle.self, from: data)
            return puzzle
        } catch {
            print("Error decoding puzzle: \(error)")
            return nil
        }
    }

    // Example of retrieving a localized UI string (standard iOS localization)
    func localizedString(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}
