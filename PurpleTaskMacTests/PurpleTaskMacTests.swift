//
//  PurpleTaskMacTests.swift
//  PurpleTaskMacTests
//
//  Unit tests for PurpleTaskMac
//

import XCTest
import SwiftData
@testable import PurpleTaskMac

final class PurpleTaskMacTests: XCTestCase {

    var modelContainer: ModelContainer!

    override func setUpWithError() throws {
        let schema = Schema([TaskItem.self, Category.self])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [config])
    }

    override func tearDownWithError() throws {
        modelContainer = nil
    }

    // MARK: - Task Tests

    func testTaskCreation() throws {
        let context = modelContainer.mainContext

        let task = TaskItem(name: "Test Task")
        context.insert(task)

        XCTAssertEqual(task.name, "Test Task")
        XCTAssertFalse(task.isDone)
        XCTAssertNil(task.category)
        XCTAssertNil(task.dueDate)
    }

    func testTaskToggleDone() throws {
        let task = TaskItem(name: "Test Task")

        XCTAssertFalse(task.isDone)
        XCTAssertNil(task.doneAt)

        task.toggleDone()

        XCTAssertTrue(task.isDone)
        XCTAssertNotNil(task.doneAt)

        task.toggleDone()

        XCTAssertFalse(task.isDone)
        XCTAssertNil(task.doneAt)
    }

    func testTaskDueDateCategory() throws {
        let calendar = Calendar.current

        // No date
        let taskNoDate = TaskItem(name: "No Date Task")
        XCTAssertEqual(taskNoDate.dueDateCategory, .noDate)

        // Today
        let taskToday = TaskItem(name: "Today Task", dueDate: Date())
        XCTAssertEqual(taskToday.dueDateCategory, .today)

        // Tomorrow
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date())!
        let taskTomorrow = TaskItem(name: "Tomorrow Task", dueDate: tomorrow)
        XCTAssertEqual(taskTomorrow.dueDateCategory, .tomorrow)

        // Overdue
        let yesterday = calendar.date(byAdding: .day, value: -1, to: Date())!
        let taskOverdue = TaskItem(name: "Overdue Task", dueDate: yesterday)
        XCTAssertEqual(taskOverdue.dueDateCategory, .overdue)

        // Later
        let nextWeek = calendar.date(byAdding: .day, value: 7, to: Date())!
        let taskLater = TaskItem(name: "Later Task", dueDate: nextWeek)
        XCTAssertEqual(taskLater.dueDateCategory, .later)
    }

    // MARK: - Category Tests

    func testCategoryCreation() throws {
        let context = modelContainer.mainContext

        let category = Category(name: "Test Category")
        context.insert(category)

        XCTAssertEqual(category.name, "Test Category")
        XCTAssertEqual(category.iconName, "folder.fill")
        XCTAssertTrue(category.taskList.isEmpty)
    }

    func testCategoryCompletionPercentage() throws {
        let context = modelContainer.mainContext

        let category = Category(name: "Test Category")
        context.insert(category)

        // Empty category
        XCTAssertEqual(category.completionPercentage, 0)

        // Add tasks
        let task1 = TaskItem(name: "Task 1", category: category)
        let task2 = TaskItem(name: "Task 2", category: category)
        let task3 = TaskItem(name: "Task 3", category: category)

        context.insert(task1)
        context.insert(task2)
        context.insert(task3)

        // No tasks completed
        XCTAssertEqual(category.completionPercentage, 0)

        // Complete one task
        task1.toggleDone()
        XCTAssertEqual(category.completionPercentage, 1.0/3.0, accuracy: 0.01)

        // Complete all tasks
        task2.toggleDone()
        task3.toggleDone()
        XCTAssertEqual(category.completionPercentage, 1.0)
    }

    func testCategoryColors() throws {
        for categoryColor in CategoryColor.allCases {
            XCTAssertFalse(categoryColor.hex.isEmpty)
            XCTAssertNotNil(categoryColor.color)
        }
    }
}
