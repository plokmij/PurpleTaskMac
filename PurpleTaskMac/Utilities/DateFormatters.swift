//
//  DateFormatters.swift
//  PurpleTaskMac
//
//  Date and time formatting utilities
//

import Foundation

enum DateFormatters {
    // MARK: - Shared Formatters

    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()

    static let mediumDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    static let longDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    static let isoDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static let time12Hour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_US")
        return formatter
    }()

    static let time24Hour: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "en_GB")
        return formatter
    }()

    // MARK: - Formatting Functions

    static func formatDate(_ date: Date, style: DateFormatOption) -> String {
        switch style {
        case .short:
            return shortDate.string(from: date)
        case .medium:
            return mediumDate.string(from: date)
        case .long:
            return longDate.string(from: date)
        case .iso:
            return isoDate.string(from: date)
        }
    }

    static func formatTime(_ date: Date, use24Hour: Bool) -> String {
        if use24Hour {
            return time24Hour.string(from: date)
        } else {
            return time12Hour.string(from: date)
        }
    }

    static func formatDateTime(_ date: Date, dateStyle: DateFormatOption, use24Hour: Bool) -> String {
        "\(formatDate(date, style: dateStyle)) \(formatTime(date, use24Hour: use24Hour))"
    }

    // MARK: - Relative Date Formatting

    static func relativeDateString(for date: Date) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDate = calendar.startOfDay(for: date)

        if targetDate < today {
            let days = calendar.dateComponents([.day], from: targetDate, to: today).day ?? 0
            if days == 1 {
                return "Yesterday"
            } else {
                return "\(days) days ago"
            }
        } else if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let days = calendar.dateComponents([.day], from: today, to: targetDate).day ?? 0
            if days < 7 {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                return formatter.string(from: date)
            } else {
                return mediumDate.string(from: date)
            }
        }
    }
}
