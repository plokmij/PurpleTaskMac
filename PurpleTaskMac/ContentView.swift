//
//  ContentView.swift
//  PurpleTaskMac
//
//  Main window with NavigationSplitView
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.position) private var categories: [Category]
    @Query private var allTasks: [TaskItem]

    @State private var selectedCategory: Category?
    @State private var showUncategorized = false
    @State private var showNewCategorySheet = false
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    private var uncategorizedTasks: [TaskItem] {
        allTasks.filter { $0.category == nil }
    }

    private var totalIncompleteTasks: Int {
        allTasks.filter { !$0.isDone }.count
    }

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(
                categories: categories,
                uncategorizedTasks: uncategorizedTasks,
                totalIncompleteTasks: totalIncompleteTasks,
                selectedCategory: $selectedCategory,
                showUncategorized: $showUncategorized,
                showNewCategorySheet: $showNewCategorySheet
            )
        } detail: {
            if showUncategorized {
                TaskListView(
                    category: nil,
                    tasks: uncategorizedTasks,
                    title: "Uncategorized",
                    icon: "tray.fill",
                    color: .secondary
                )
            } else if let category = selectedCategory {
                TaskListView(
                    category: category,
                    tasks: category.taskList,
                    title: category.name,
                    icon: category.iconName,
                    color: category.color
                )
            } else {
                ContentUnavailableView {
                    Label("Select a Category", systemImage: "sidebar.left")
                } description: {
                    Text("Choose a category from the sidebar to view its tasks.")
                }
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { openAboutWindow() }) {
                    Label("About", systemImage: "info.circle")
                }

                SettingsLink {
                    Label("Settings", systemImage: "gearshape")
                }
            }
        }
        .sheet(isPresented: $showNewCategorySheet) {
            NewCategorySheet(isPresented: $showNewCategorySheet)
        }
        .onReceive(NotificationCenter.default.publisher(for: .newCategory)) { _ in
            showNewCategorySheet = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .newTask)) { _ in
            // Focus on add task field - handled in TaskListView
        }
    }

    private func openAboutWindow() {
        if let window = NSApp.windows.first(where: { $0.identifier?.rawValue == "about" }) {
            window.makeKeyAndOrderFront(nil)
        } else {
            NSWorkspace.shared.open(URL(string: "purpletask://about")!)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
