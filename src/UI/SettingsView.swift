import SwiftUI

struct SettingsView: View {
    @ObservedObject var themeManager = AppThemeManager.shared
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle(isOn: $themeManager.isDarkMode) {
                        HStack {
                            Image(systemName: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                                .foregroundColor(themeManager.isDarkMode ? .purple : .orange)
                            Text("Dark Mode")
                        }
                    }
                }

                Section(header: Text("Cultural Theme")) {
                    Picker("Select Theme", selection: $themeManager.selectedThemeId) {
                        Text("English (Classic)").tag("en_classic")
                        Text("Turkish (Local)").tag("tr_local")
                        Text("Japanese (Anime)").tag("ja_anime")
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("About")) {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2026.1.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
