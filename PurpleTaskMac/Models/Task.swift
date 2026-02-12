//
//  Task.swift
//  PurpleTaskMac
//
//  SwiftData model for tasks
//

import Foundation
import SwiftData

@Model
final class TaskItem {
    var id: UUID
    var name: String
    var taskDescription: String?
    var isDone: Bool
    var category: Category?
    var createdAt: Date
    var dueDate: Date?
    var doneAt: Date?
    var position: Int

    init(
        id: UUID = UUID(),
        name: String,
        taskDescription: String? = nil,
        isDone: Bool = false,
        category: Category? = nil,
        createdAt: Date = Date(),
        dueDate: Date? = nil,
        doneAt: Date? = nil,
        position: Int = 0
    ) {
        self.id = id
        self.name = name
        self.taskDescription = taskDescription
        self.isDone = isDone
        self.category = category
        self.createdAt = createdAt
        self.dueDate = dueDate
        self.doneAt = doneAt
        self.position = position
    }
}

// MARK: - TaskItem Extensions
extension TaskItem {
    var dueDateCategory: DueDateCategory {
        guard let dueDate = dueDate else {
            return .noDate
        }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dueDateStart = calendar.startOfDay(for: dueDate)

        if dueDateStart < today {
            return .overdue
        } else if calendar.isDateInToday(dueDate) {
            return .today
        } else if calendar.isDateInTomorrow(dueDate) {
            return .tomorrow
        } else {
            return .later
        }
    }

    func toggleDone() {
        isDone.toggle()
        doneAt = isDone ? Date() : nil
    }
}

// MARK: - Due Date Category
enum DueDateCategory: String, CaseIterable, Identifiable {
    case overdue = "Overdue"
    case today = "Today"
    case tomorrow = "Tomorrow"
    case later = "Later"
    case noDate = "No Date"

    var id: String { rawValue }

    var sortOrder: Int {
        switch self {
        case .overdue: return 0
        case .today: return 1
        case .tomorrow: return 2
        case .later: return 3
        case .noDate: return 4
        }
    }
}

// MARK: - Task Filter
enum TaskFilter: String, CaseIterable, Identifiable {
    case todo = "To Do"
    case all = "All"
    case completed = "Completed"

    var id: String { rawValue }
}
