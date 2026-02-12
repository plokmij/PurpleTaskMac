//
//  AddTaskField.swift
//  PurpleTaskMac
//
//  New task input field
//

import SwiftUI
import SwiftData

struct AddTaskField: View {
    let category: Category?
    @FocusState var isAddTaskFocused: Bool

    @Environment(\.modelContext) private var modelContext
    @State private var newTaskName = ""

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundStyle(.purple)

            TextField("Add new task", text: $newTaskName)
                .textFieldStyle(.plain)
                .focused($isAddTaskFocused)
                .onSubmit {
                    addTask()
                }

            if !newTaskName.isEmpty {
                Button(action: addTask) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.purple)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
    }

    private func addTask() {
        guard !newTaskName.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        let task = TaskItem(
            name: newTaskName.trimmingCharacters(in: .whitespaces),
            category: category,
            position: getNextPosition()
        )

        modelContext.insert(task)
        newTaskName = ""
    }

    private func getNextPosition() -> Int {
        if let category = category {
            return (category.taskList.map(\.position).max() ?? -1) + 1
        }
        // For uncategorized, get max position from all uncategorized tasks
        let descriptor = FetchDescriptor<TaskItem>(
            predicate: #Predicate { $0.category == nil }
        )
        let tasks = (try? modelContext.fetch(descriptor)) ?? []
        return (tasks.map(\.position).max() ?? -1) + 1
    }
}

#Preview {
    AddTaskField(category: nil)
        .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
