//
//  NewCategorySheet.swift
//  PurpleTaskMac
//
//  Multi-step category creation wizard
//

import SwiftUI
import SwiftData

struct NewCategorySheet: View {
    @Binding var isPresented: Bool

    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Category.position) private var existingCategories: [Category]

    @State private var currentStep = 0
    @State private var categoryName = ""
    @State private var selectedColor: CategoryColor = .purple
    @State private var selectedIcon = "folder.fill"
    @State private var initialTasks: [String] = []
    @State private var newTaskText = ""

    private let totalSteps = 5

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Category")
                    .font(.headline)

                Spacer()

                Button(action: { isPresented = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()

            Divider()

            // Content
            VStack(spacing: 24) {
                // Category preview
                CategoryPreview(
                    name: categoryName.isEmpty ? "?" : categoryName,
                    color: selectedColor.color,
                    icon: selectedIcon,
                    showIcon: currentStep >= 3
                )

                // Step content
                stepContent
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Divider()

            // Navigation buttons
            HStack {
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation {
                            currentStep -= 1
                        }
                    }
                }

                Spacer()

                // Step indicator
                HStack(spacing: 6) {
                    ForEach(0..<totalSteps, id: \.self) { step in
                        Circle()
                            .fill(step == currentStep ? Color.purple : Color.secondary.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }

                Spacer()

                if currentStep < totalSteps - 1 {
                    Button("Next") {
                        withAnimation {
                            currentStep += 1
                        }
                    }
                    .disabled(currentStep == 1 && categoryName.isEmpty)
                    .keyboardShortcut(.defaultAction)
                } else {
                    Button("Finish") {
                        createCategory()
                    }
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding()
        }
        .frame(width: 400, height: 500)
        .background(.regularMaterial)
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            // Welcome step
            VStack(spacing: 16) {
                Text("Create a new category to organize your tasks")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)

                Text("Press Next to start")
                    .font(.callout)
                    .foregroundStyle(.tertiary)
            }

        case 1:
            // Name step
            VStack(spacing: 16) {
                Text("What's the name of this category?")
                    .font(.subheadline)

                TextField("Category name", text: $categoryName)
                    .textFieldStyle(.roundedBorder)
                    .textContentType(.none)
                    .autocorrectionDisabled()
                    .frame(maxWidth: 250)
            }

        case 2:
            // Color step
            VStack(spacing: 16) {
                Text("Choose a color")
                    .font(.subheadline)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 5), spacing: 12) {
                    ForEach(CategoryColor.allCases) { color in
                        Circle()
                            .fill(color.color)
                            .frame(width: 36, height: 36)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                            )
                            .onTapGesture {
                                selectedColor = color
                            }
                    }
                }
            }

        case 3:
            // Icon step
            VStack(spacing: 16) {
                Text("Choose an icon")
                    .font(.subheadline)

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 6), spacing: 12) {
                        ForEach(CategoryIcons.all, id: \.self) { icon in
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedIcon == icon ? selectedColor.color.opacity(0.2) : Color.clear)
                                    .frame(width: 40, height: 40)

                                Image(systemName: icon)
                                    .font(.title3)
                                    .foregroundStyle(selectedIcon == icon ? selectedColor.color : .secondary)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(selectedIcon == icon ? selectedColor.color : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture {
                                selectedIcon = icon
                            }
                        }
                    }
                }
                .frame(height: 180)
            }

        case 4:
            // Add tasks step
            VStack(spacing: 16) {
                Text("Add some tasks (optional)")
                    .font(.subheadline)

                HStack {
                    TextField("Task name", text: $newTaskText)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.none)
                        .autocorrectionDisabled()
                        .onSubmit {
                            addTask()
                        }

                    Button(action: addTask) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundStyle(.purple)
                    }
                    .buttonStyle(.plain)
                    .disabled(newTaskText.isEmpty)
                }

                if !initialTasks.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(initialTasks, id: \.self) { task in
                                HStack {
                                    Image(systemName: "circle")
                                        .foregroundStyle(.secondary)
                                    Text(task)
                                    Spacer()
                                    Button(action: { removeTask(task) }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.secondary)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                            }
                        }
                    }
                    .frame(maxHeight: 150)
                }
            }

        default:
            EmptyView()
        }
    }

    private func addTask() {
        let trimmed = newTaskText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        initialTasks.append(trimmed)
        newTaskText = ""
    }

    private func removeTask(_ task: String) {
        initialTasks.removeAll { $0 == task }
    }

    private func createCategory() {
        let category = Category(
            name: categoryName,
            colorHex: selectedColor.hex,
            iconName: selectedIcon,
            position: (existingCategories.map(\.position).max() ?? -1) + 1
        )

        modelContext.insert(category)

        // Add initial tasks
        for (index, taskName) in initialTasks.enumerated() {
            let task = TaskItem(
                name: taskName,
                category: category,
                position: index
            )
            modelContext.insert(task)
        }

        isPresented = false
    }
}

// MARK: - Category Preview
struct CategoryPreview: View {
    let name: String
    let color: Color
    let icon: String
    let showIcon: Bool

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(color.opacity(0.2))
                    .frame(width: 64, height: 64)

                if showIcon {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundStyle(color)
                } else {
                    Text("?")
                        .font(.title)
                        .foregroundStyle(color)
                }
            }

            Text(name)
                .font(.headline)
        }
    }
}

#Preview {
    NewCategorySheet(isPresented: .constant(true))
        .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
