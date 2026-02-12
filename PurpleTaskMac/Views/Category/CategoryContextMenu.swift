//
//  CategoryContextMenu.swift
//  PurpleTaskMac
//
//  Context menu for category actions
//

import SwiftUI
import SwiftData

struct CategoryContextMenu: View {
    @Bindable var category: Category
    @Binding var showRenameAlert: Bool
    @Binding var showColorPicker: Bool
    @Binding var showIconPicker: Bool
    @Binding var showDeleteAlert: Bool

    @Environment(\.modelContext) private var modelContext

    var body: some View {
        Group {
            // Edit actions
            Button {
                showRenameAlert = true
            } label: {
                Label("Change Name", systemImage: "pencil")
            }

            Button {
                showColorPicker = true
            } label: {
                Label("Change Color", systemImage: "paintpalette")
            }

            Button {
                showIconPicker = true
            } label: {
                Label("Change Icon", systemImage: "star.square")
            }

            Divider()

            // Task management
            Button {
                deleteCompletedTasks()
            } label: {
                Label("Delete Completed Tasks", systemImage: "checkmark.circle")
            }
            .disabled(category.completedTasks.isEmpty)

            Button {
                deleteAllTasks()
            } label: {
                Label("Delete All Tasks", systemImage: "trash")
            }
            .disabled(category.taskList.isEmpty)

            Divider()

            // Delete category
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete Category", systemImage: "folder.badge.minus")
            }
        }
    }

    private func deleteCompletedTasks() {
        for task in category.completedTasks {
            modelContext.delete(task)
        }
    }

    private func deleteAllTasks() {
        for task in category.taskList {
            modelContext.delete(task)
        }
    }
}

#Preview {
    let category = Category(name: "Test")
    return Text("Right-click me")
        .contextMenu {
            CategoryContextMenu(
                category: category,
                showRenameAlert: .constant(false),
                showColorPicker: .constant(false),
                showIconPicker: .constant(false),
                showDeleteAlert: .constant(false)
            )
        }
        .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
