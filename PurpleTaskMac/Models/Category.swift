//
//  Category.swift
//  PurpleTaskMac
//
//  SwiftData model for categories
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var id: UUID
    var name: String
    var colorHex: String
    var iconName: String
    var position: Int

    @Relationship(deleteRule: .cascade, inverse: \TaskItem.category)
    var tasks: [TaskItem]?

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = CategoryColor.purple.hex,
        iconName: String = "folder.fill",
        position: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.position = position
        self.tasks = []
    }

    var color: Color {
        Color(hex: colorHex) ?? .purple
    }

    var taskList: [TaskItem] {
        tasks ?? []
    }

    var incompleteTasks: [TaskItem] {
        taskList.filter { !$0.isDone }
    }

    var completedTasks: [TaskItem] {
        taskList.filter { $0.isDone }
    }

    var completionPercentage: Double {
        guard !taskList.isEmpty else { return 0 }
        return Double(completedTasks.count) / Double(taskList.count)
    }
}

// MARK: - Category Color
enum CategoryColor: String, CaseIterable, Identifiable {
    case red, orange, yellow, green, mint, teal, cyan, blue
    case indigo, purple, pink, brown, gray

    var id: String { rawValue }

    var hex: String {
        switch self {
        case .red: return "#FF3B30"
        case .orange: return "#FF9500"
        case .yellow: return "#FFCC00"
        case .green: return "#34C759"
        case .mint: return "#00C7BE"
        case .teal: return "#30B0C7"
        case .cyan: return "#32ADE6"
        case .blue: return "#007AFF"
        case .indigo: return "#5856D6"
        case .purple: return "#AF52DE"
        case .pink: return "#FF2D55"
        case .brown: return "#A2845E"
        case .gray: return "#8E8E93"
        }
    }

    var color: Color {
        Color(hex: hex) ?? .purple
    }
}

// MARK: - Category Icons
struct CategoryIcons {
    static let all: [String] = [
        "house.fill", "briefcase.fill", "cart.fill", "book.fill",
        "gamecontroller.fill", "figure.run", "airplane", "music.note",
        "fork.knife", "film.fill", "iphone", "laptopcomputer",
        "car.fill", "sportscourt.fill", "paintbrush.fill", "camera.fill",
        "heart.fill", "star.fill", "bolt.fill", "leaf.fill",
        "graduationcap.fill", "wrench.fill", "gift.fill", "flag.fill"
    ]
}

// MARK: - Color Extension
extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }

        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b)
    }
}
