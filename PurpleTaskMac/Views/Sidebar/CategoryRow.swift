//
//  CategoryRow.swift
//  PurpleTaskMac
//
//  Individual category row in sidebar
//

import SwiftUI
import SwiftData

struct CategoryRow: View {
    @Bindable var category: Category
    let isSelected: Bool

    @Environment(\.modelContext) private var modelContext
    @State private var showRenameAlert = false
    @State private var showDeleteAlert = false
    @State private var showColorPicker = false
    @State private var showIconPicker = false
    @State private var newName: String = ""

    var body: some View {
        HStack(spacing: 12) {
            // Icon with color background
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(category.color.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: category.iconName)
                    .font(.system(size: 14))
                    .foregroundStyle(category.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(category.name)
                    .fontWeight(.medium)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Text("\(category.incompleteTasks.count) tasks left")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Progress bar
                if !category.taskList.isEmpty {
                    ProgressView(value: category.completionPercentage)
                        .tint(category.color)
                        .scaleEffect(x: 1, y: 0.5, anchor: .center)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(6)
        .contextMenu {
            CategoryContextMenu(
                category: category,
                showRenameAlert: $showRenameAlert,
                showColorPicker: $showColorPicker,
                showIconPicker: $showIconPicker,
                showDeleteAlert: $showDeleteAlert
            )
        }
        .alert("Rename Category", isPresented: $showRenameAlert) {
            TextField("Category name", text: $newName)
            Button("Cancel", role: .cancel) { }
            Button("Rename") {
                if !newName.isEmpty {
                    category.name = newName
                }
            }
        } message: {
            Text("Enter a new name for this category")
        }
        .alert("Delete Category", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteCategory()
            }
        } message: {
            Text("This will delete the category and all its tasks. This action cannot be undone.")
        }
        .sheet(isPresented: $showColorPicker) {
            ColorPickerSheet(
                selectedColor: Binding(
                    get: { CategoryColor.allCases.first { $0.hex == category.colorHex } ?? .purple },
                    set: { category.colorHex = $0.hex }
                ),
                isPresented: $showColorPicker
            )
        }
        .sheet(isPresented: $showIconPicker) {
            IconPickerSheet(
                selectedIcon: $category.iconName,
                color: category.color,
                isPresented: $showIconPicker
            )
        }
        .onAppear {
            newName = category.name
        }
    }

    private func deleteCategory() {
        withAnimation {
            modelContext.delete(category)
        }
    }
}

// MARK: - Color Picker Sheet
struct ColorPickerSheet: View {
    @Binding var selectedColor: CategoryColor
    @Binding var isPresented: Bool

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 5)

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Color")
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(CategoryColor.allCases) { color in
                    Circle()
                        .fill(color.color)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.primary, lineWidth: selectedColor == color ? 3 : 0)
                        )
                        .onTapGesture {
                            selectedColor = color
                        }
                }
            }
            .padding()

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Done") {
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 300)
    }
}

// MARK: - Icon Picker Sheet
struct IconPickerSheet: View {
    @Binding var selectedIcon: String
    let color: Color
    @Binding var isPresented: Bool

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 6)

    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Icon")
                .font(.headline)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(CategoryIcons.all, id: \.self) { icon in
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedIcon == icon ? color.opacity(0.2) : Color.clear)
                                .frame(width: 44, height: 44)

                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(selectedIcon == icon ? color : .secondary)
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedIcon == icon ? color : Color.clear, lineWidth: 2)
                        )
                        .onTapGesture {
                            selectedIcon = icon
                        }
                    }
                }
                .padding()
            }
            .frame(height: 200)

            HStack {
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Done") {
                    isPresented = false
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .frame(width: 350)
    }
}

#Preview {
    let category = Category(name: "Home", colorHex: CategoryColor.blue.hex, iconName: "house.fill")
    CategoryRow(category: category, isSelected: false)
        .modelContainer(for: [TaskItem.self, Category.self], inMemory: true)
}
