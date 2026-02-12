//
//  PurpleTaskMacApp.swift
//  PurpleTaskMac
//
//  A native macOS task management app
//

import SwiftUI
import SwiftData

@main
struct PurpleTaskMacApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TaskItem.self,
            Category.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("appearance") private var appearance: AppearanceMode = .system
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(appearance.colorScheme)
                .sheet(isPresented: .constant(!hasLaunchedBefore)) {
                    WelcomeView(isPresented: .init(
                        get: { !hasLaunchedBefore },
                        set: { if !$0 { hasLaunchedBefore = true } }
                    ))
                }
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Task") {
                    NotificationCenter.default.post(name: .newTask, object: nil)
                }
                .keyboardShortcut("n", modifiers: .command)

                Button("New Category") {
                    NotificationCenter.default.post(name: .newCategory, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command, .shift])
            }
        }

        Settings {
            SettingsView()
        }

        Window("About Purple Task", id: "about") {
            AboutView()
        }
        .windowResizability(.contentSize)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let newTask = Notification.Name("newTask")
    static let newCategory = Notification.Name("newCategory")
}

// MARK: - Appearance Mode
enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
