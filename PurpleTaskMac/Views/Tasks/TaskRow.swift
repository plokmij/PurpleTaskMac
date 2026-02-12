//
//  TaskRow.swift
//  PurpleTaskMac
//
//  Individual task row with checkbox and context menu
//

import SwiftUI
import SwiftData

struct TaskRow: View {
    @Bindable var task: TaskItem
    let categoryColor: Color

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.position) private var allCategories: [Category]

    @State private var isHovered = false
    @State private var showDatePicker = false
    @State private var showDeleteAlert = false

    @AppStorage("showCompletionTime") private var showCompletionTime = true
    @AppStorage("use24HourTime") private var use24HourTime = true

    var body: some View {
        HStack(spacing: 12) {
            // Checkbox
            Button(action: { task.toggleDone() }) {
                Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isDone ? categoryColor : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(task.name)
                    .strikethrough(task.isDone)
                    .foregroundStyle(task.isDone ? .secondary : .primary)

                if let description = task.taskDescription, !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                // Due date or completion time
                if let dueDate = task.dueDate, !task.isDone {
                    DueDateLabel(date: dueDate, category: task.dueDateCategory, use24Hour: use24HourTime)
                } else if task.isDone, showCompletionTime, let doneAt = task.doneAt {
                    Text("Completed \(formattedDate(doneAt))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Drag handle (visible on hover)
            if isHovered {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isHovered ? Color(nsColor: .controlBackgroundColor) : Color.clear)
        )
        .onHover { hovering in
            isHovered = hovering
        }
        .contextMenu {
            TaskContextMenu(
                task: task,
                categories: allCategories,
                showDatePicker: $showDatePicker,
                showDeleteAlert: $showDeleteAlert
            )
        }
        .alert("Delete Task", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteTask()
            }
        } message: {
            Text("Are you sure you want to delete this task?")
        }
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(
                selectedDate: $task.dueDate,
                isPresented: $showDatePicker
            )
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        if use24HourTime {
            formatter.locale = Locale(identifier: "en_GB")
        }
        return formatter.string(from: date)
    }

    private func deleteTask() {
        withAnimation {
            modelContext.delete(task)
        }
    }
}

// MARK: - Due Date Label
struct DueDateLabel: View {
    let date: Date
    let category: DueDateCategory
    let use24Hour: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "calendar")
                .font(.caption2)

            Text(formattedDueDate)
                .font(.caption)
        }
        .foregroundStyle(category == .overdue ? .red : .secondary)
    }

    private var formattedDueDate: String {
        switch category {
        case .overdue, .later:
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return "Due: \(formatter.string(from: date))"
        case .today:
            return "Due: Today"
        case .tomorrow:
            return "Due: Tomorrow"
        case .noDate:
            return ""
        }
    }
}

// MARK: - Date Picker Sheet
struct DatePickerSheet: View {
    @Binding var selectedDate: Date?
    @Binding var isPresented: Bool

    @State private var tempDate = Date()
    @State private var hasDate = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Set Due Date")
                .font(.headline)

            HStack(spacing: 12) {
                Button("Today") {
                    tempDate = Calendar.current.startOfDay(for: Date())
                    hasDate = true
                }

                Button("Tomorrow") {
                    tempDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
                    hasDate = true
                }

                Button("No Date") {
                    hasDate = false
                }
            }

            DatePicker(
                "Custom Date",
                selection: $tempDate,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .onChange(of: tempDate) { _, _ in
                hasDate = true
            }

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    selectedDate = hasDate ? tempDate : nil
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 320)
        .onAppear {
            if let date = selectedDate {
                tempDate = date
                hasDate = true
            }
        }
    }
}

#Preview {
    let task = TaskItem(name: "Sample Task")
    return TaskRow(task: task, categoryColor: .purple)
        .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
