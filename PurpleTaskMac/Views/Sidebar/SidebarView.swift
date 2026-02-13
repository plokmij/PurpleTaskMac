//
//  SidebarView.swift
//  PurpleTaskMac
//
//  Category list sidebar
//

import SwiftUI
import SwiftData

struct SidebarView: View {
    let categories: [Category]
    let uncategorizedTasks: [TaskItem]
    let totalIncompleteTasks: Int
    @Binding var selectedCategory: Category?
    @Binding var showUncategorized: Bool
    @Binding var showNewCategorySheet: Bool

    @Environment(\.modelContext) private var modelContext
    @State private var draggedCategory: Category?

    var body: some View {
        List(selection: Binding(
            get: { showUncategorized ? nil : selectedCategory },
            set: { newValue in
                if let category = newValue {
                    selectedCategory = category
                    showUncategorized = false
                }
            }
        )) {
            // Greeting header
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello!")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("You have \(totalIncompleteTasks) tasks to complete")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }

            // Uncategorized section
            Section {
                UncategorizedRow(
                    taskCount: uncategorizedTasks.filter { !$0.isDone }.count,
                    isSelected: showUncategorized
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    showUncategorized = true
                    selectedCategory = nil
                }
            }

            // Categories section
            Section("Categories") {
                ForEach(categories) { category in
                    CategoryRow(
                        category: category,
                        isSelected: selectedCategory?.id == category.id && !showUncategorized
                    )
                    .tag(category)
                    .onDrag {
                        draggedCategory = category
                        return NSItemProvider(object: category.id.uuidString as NSString)
                    }
                    .onDrop(of: [.text], delegate: CategoryDropDelegate(
                        item: category,
                        items: categories,
                        draggedItem: $draggedCategory,
                        modelContext: modelContext
                    ))
                }
            }

            // Add category button
            Section {
                Button(action: { showNewCategorySheet = true }) {
                    Label("Add Category", systemImage: "plus.circle.fill")
                        .foregroundStyle(.purple)
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.sidebar)
        .frame(minWidth: 200)
    }
}

// MARK: - Uncategorized Row
struct UncategorizedRow: View {
    let taskCount: Int
    let isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "tray.fill")
                .font(.title2)
                .foregroundStyle(.secondary)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text("Uncategorized")
                    .fontWeight(.medium)
                Text("\(taskCount) tasks")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
    }
}

// MARK: - Category Drop Delegate
struct CategoryDropDelegate: DropDelegate {
    let item: Category
    let items: [Category]
    @Binding var draggedItem: Category?
    let modelContext: ModelContext

    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let draggedItem = draggedItem,
              draggedItem.id != item.id else { return }

        let fromIndex = items.firstIndex(where: { $0.id == draggedItem.id })
        let toIndex = items.firstIndex(where: { $0.id == item.id })

        guard let from = fromIndex, let to = toIndex, from != to else { return }

        withAnimation {
            // Update positions
            let movingUp = from > to
            for (index, category) in items.enumerated() {
                if category.id == draggedItem.id {
                    category.position = to
                } else if movingUp && index >= to && index < from {
                    category.position = index + 1
                } else if !movingUp && index > from && index <= to {
                    category.position = index - 1
                }
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

#Preview {
    SidebarView(
        categories: [],
        uncategorizedTasks: [],
        totalIncompleteTasks: 5,
        selectedCategory: .constant(nil),
        showUncategorized: .constant(false),
        showNewCategorySheet: .constant(false)
    )
    .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
