//
//  SettingsView.swift
//  PurpleTaskMac
//
//  Preferences window
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") private var appearance: AppearanceMode = .system
    @AppStorage("language") private var language: AppLanguage = .english
    @AppStorage("use24HourTime") private var use24HourTime = true
    @AppStorage("dateFormat") private var dateFormat: DateFormatOption = .medium
    @AppStorage("showCompletionTime") private var showCompletionTime = true

    var body: some View {
        Form {
            // Language
            Picker("Language", selection: $language) {
                ForEach(AppLanguage.allCases) { lang in
                    Text(lang.displayName).tag(lang)
                }
            }

            Divider()

            // Appearance
            Picker("Theme", selection: $appearance) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }

            Divider()

            // Time format
            Picker("Time Format", selection: $use24HourTime) {
                Text("12-hour").tag(false)
                Text("24-hour").tag(true)
            }

            Divider()

            // Date format
            Picker("Date Format", selection: $dateFormat) {
                ForEach(DateFormatOption.allCases) { format in
                    Text(format.example).tag(format)
                }
            }

            Divider()

            // Show completion time
            Toggle("Display task's completion time", isOn: $showCompletionTime)
        }
        .formStyle(.grouped)
        .padding()
        .frame(width: 400, height: 350)
    }
}

// MARK: - App Language
enum AppLanguage: String, CaseIterable, Identifiable {
    case english = "en"
    case german = "de"
    case french = "fr"
    case polish = "pl"
    case danish = "da"
    case filipino = "fil"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .english: return "English"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .polish: return "Polski"
        case .danish: return "Dansk"
        case .filipino: return "Filipino"
        }
    }
}

// MARK: - Date Format Option
enum DateFormatOption: String, CaseIterable, Identifiable {
    case short = "short"
    case medium = "medium"
    case long = "long"
    case iso = "iso"

    var id: String { rawValue }

    var example: String {
        let formatter = DateFormatter()
        let date = Date()

        switch self {
        case .short:
            formatter.dateStyle = .short
        case .medium:
            formatter.dateStyle = .medium
        case .long:
            formatter.dateStyle = .long
        case .iso:
            formatter.dateFormat = "yyyy-MM-dd"
        }

        return formatter.string(from: date)
    }
}

#Preview {
    SettingsView()
}
