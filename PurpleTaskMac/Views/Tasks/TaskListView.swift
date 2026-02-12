//
//  TaskListView.swift
//  PurpleTaskMac
//
//  Main task list with filtering and grouping
//

import SwiftUI
import SwiftData

struct TaskListView: View {
    let category: Category?
    let tasks: [TaskItem]
    let title: String
    let icon: String
    let color: Color

    @Environment(\.modelContext) private var modelContext
    @State private var filter: TaskFilter = .todo
    @State private var draggedTask: TaskItem?
    @FocusState private var isAddTaskFocused: Bool

    private var filteredTasks: [TaskItem] {
        switch filter {
        case .todo:
            return tasks.filter { !$0.isDone }
        case .all:
            return tasks
        case .completed:
            return tasks.filter { $0.isDone }
        }
    }

    private var groupedTasks: [(DueDateCategory, [TaskItem])] {
        let groups = Dictionary(grouping: filteredTasks) { $0.dueDateCategory }
        return DueDateCategory.allCases
            .filter { groups[$0] != nil }
            .map { ($0, groups[$0]!.sorted { $0.position < $1.position }) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            CategoryHeader(
                title: title,
                icon: icon,
                color: color,
                taskCount: tasks.filter { !$0.isDone }.count,
                completionPercentage: tasks.isEmpty ? 0 : Double(tasks.filter { $0.isDone }.count) / Double(tasks.count)
            )

            // Filter picker
            Picker("Filter", selection: $filter) {
                ForEach(TaskFilter.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)

            Divider()

            // Task list
            if filteredTasks.isEmpty {
                ContentUnavailableView {
                    Label(emptyStateTitle, systemImage: emptyStateIcon)
                } description: {
                    Text(emptyStateDescription)
                }
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(groupedTasks, id: \.0) { group, groupTasks in
                            Section {
                                ForEach(groupTasks) { task in
                                    TaskRow(task: task, categoryColor: color)
                                        .onDrag {
                                            draggedTask = task
                                            return NSItemProvider(object: task.id.uuidString as NSString)
                                        }
                                        .onDrop(of: [.text], delegate: TaskDropDelegate(
                                            item: task,
                                            items: filteredTasks,
                                            draggedItem: $draggedTask,
                                            modelContext: modelContext
                                        ))
                                }
                            } header: {
                                if group != .noDate || filteredTasks.contains(where: { $0.dueDateCategory != .noDate }) {
                                    Text(group.rawValue.uppercased())
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(group == .overdue ? .red : .secondary)
                                        .padding(.horizontal)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
            }

            Divider()

            // Add task field
            AddTaskField(category: category, isAddTaskFocused: _isAddTaskFocused)
                .padding()
        }
        .onReceive(NotificationCenter.default.publisher(for: .newTask)) { _ in
            isAddTaskFocused = true
        }
    }

    private var emptyStateTitle: String {
        switch filter {
        case .todo: return "No Tasks"
        case .all: return "No Tasks"
        case .completed: return "No Completed Tasks"
        }
    }

    private var emptyStateIcon: String {
        switch filter {
        case .todo: return "checkmark.circle"
        case .all: return "tray"
        case .completed: return "checkmark.circle.fill"
        }
    }

    private var emptyStateDescription: String {
        switch filter {
        case .todo: return "Add a task below to get started"
        case .all: return "Add a task below to get started"
        case .completed: return "Complete some tasks to see them here"
        }
    }
}

// MARK: - Category Header
struct CategoryHeader: View {
    let title: String
    let icon: String
    let color: Color
    let taskCount: Int
    let completionPercentage: Double

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("\(taskCount) tasks left")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ProgressView(value: completionPercentage)
                    .tint(color)
                    .frame(maxWidth: 200)
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Task Drop Delegate
struct TaskDropDelegate: DropDelegate {
    let item: TaskItem
    let items: [TaskItem]
    @Binding var draggedItem: TaskItem?
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
            let movingUp = from > to
            for (index, task) in items.enumerated() {
                if task.id == draggedItem.id {
                    task.position = to
                } else if movingUp && index >= to && index < from {
                    task.position = index + 1
                } else if !movingUp && index > from && index <= to {
                    task.position = index - 1
                }
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

#Preview {
    TaskListView(
        category: nil,
        tasks: [],
        title: "Uncategorized",
        icon: "tray.fill",
        color: .secondary
    )
    .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
