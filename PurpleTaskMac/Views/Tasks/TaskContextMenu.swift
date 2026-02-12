//
//  TaskContextMenu.swift
//  PurpleTaskMac
//
//  Context menu for task actions
//

import SwiftUI
import SwiftData

struct TaskContextMenu: View {
    @Bindable var task: TaskItem
    let categories: [Category]
    @Binding var showDatePicker: Bool
    @Binding var showDeleteAlert: Bool

    var body: some View {
        Group {
            // Delete
            Button(role: .destructive) {
                showDeleteAlert = true
            } label: {
                Label("Delete", systemImage: "trash")
            }

            Divider()

            // Set due date submenu
            Menu("Set Due Date") {
                Button("Today") {
                    task.dueDate = Calendar.current.startOfDay(for: Date())
                }

                Button("Tomorrow") {
                    task.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))
                }

                Button("Custom Date...") {
                    showDatePicker = true
                }

                Divider()

                Button("No Date") {
                    task.dueDate = nil
                }
            }

            Divider()

            // Move to category submenu
            Menu("Move to Category") {
                Button("Uncategorized") {
                    task.category = nil
                }

                if !categories.isEmpty {
                    Divider()

                    ForEach(categories) { category in
                        Button {
                            task.category = category
                        } label: {
                            Label(category.name, systemImage: category.iconName)
                        }
                        .disabled(task.category?.id == category.id)
                    }
                }
            }
        }
    }
}

#Preview {
    Text("Right-click me")
        .contextMenu {
            TaskContextMenu(
                task: TaskItem(name: "Test"),
                categories: [],
                showDatePicker: .constant(false),
                showDeleteAlert: .constant(false)
            )
        }
        .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
