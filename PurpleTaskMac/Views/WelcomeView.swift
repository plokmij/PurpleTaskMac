//
//  WelcomeView.swift
//  PurpleTaskMac
//
//  Welcome screen for first launch
//

import SwiftUI

struct WelcomeView: View {
    @Binding var isPresented: Bool

    var body: some View {
        VStack(spacing: 24) {
            // App icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.purple)

            // Title
            VStack(spacing: 8) {
                Text("Welcome to Purple Task")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Divider()
                .padding(.horizontal, 40)

            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(
                    icon: "checkmark.circle",
                    title: "Task Management",
                    description: "Create, edit, and organize your tasks with ease"
                )

                FeatureRow(
                    icon: "folder.fill",
                    title: "Categories",
                    description: "Group tasks into customizable categories with colors and icons"
                )

                FeatureRow(
                    icon: "calendar",
                    title: "Due Dates",
                    description: "Set due dates and track overdue tasks"
                )

                FeatureRow(
                    icon: "arrow.up.arrow.down",
                    title: "Drag & Drop",
                    description: "Reorder tasks and categories with drag and drop"
                )
            }
            .padding(.horizontal, 24)

            Spacer()

            Button(action: { isPresented = false }) {
                Text("Get Started")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .tint(.purple)
            .padding(.horizontal, 40)
        }
        .padding(.vertical, 32)
        .frame(width: 450, height: 550)
        .background(.regularMaterial)
    }
}

// MARK: - Feature Row
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.purple)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    WelcomeView(isPresented: .constant(true))
}
