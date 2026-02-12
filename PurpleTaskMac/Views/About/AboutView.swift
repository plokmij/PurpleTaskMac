//
//  AboutView.swift
//  PurpleTaskMac
//
//  About window
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            // App icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.purple)

            // App name and version
            VStack(spacing: 4) {
                Text("Purple Task")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Version 1.0.0")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Description
            Text("Simple TO-DO app to help you get stuff done")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Divider()

            // Links
            VStack(spacing: 0) {
                LinkRow(title: "License", subtitle: "MIT", url: URL(string: "https://opensource.org/licenses/MIT")!)

                Divider()

                LinkRow(title: "View Source Code", url: URL(string: "https://github.com/user/purple-task")!)

                Divider()

                LinkRow(title: "Report Issues", url: URL(string: "https://github.com/user/purple-task/issues")!)

                Divider()

                LinkRow(title: "Help with Translation", url: URL(string: "https://github.com/user/purple-task#contributing")!)
            }
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)

            Spacer()
        }
        .padding(24)
        .frame(width: 320, height: 450)
    }
}

// MARK: - Link Row
struct LinkRow: View {
    let title: String
    var subtitle: String?
    let url: URL

    var body: some View {
        Button {
            NSWorkspace.shared.open(url)
        } label: {
            HStack {
                Text(title)
                    .foregroundStyle(.primary)

                Spacer()

                if let subtitle = subtitle {
                    Text(subtitle)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    AboutView()
}
