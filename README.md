# Purple Task for macOS

A native SwiftUI macOS task management application.

## Requirements

- macOS 14.0 (Sonoma) or later
- Xcode 15.0 or later

## Features

- **Task Management**: Create, edit, and delete tasks with optional descriptions
- **Categories**: Organize tasks into customizable categories with colors and icons
- **Due Dates**: Set due dates for tasks (Today, Tomorrow, custom date)
- **Drag & Drop**: Reorder tasks and categories with drag and drop
- **Progress Tracking**: Visual progress bars showing completion percentage
- **Dark Mode**: Full support for macOS light and dark appearance
- **Keyboard Shortcuts**: Cmd+N for new task, Cmd+Shift+N for new category
- **Native macOS UI**: Built with SwiftUI and follows macOS design guidelines

## Project Structure

```
PurpleTaskMac/
├── PurpleTaskMacApp.swift          # App entry point
├── ContentView.swift               # Main NavigationSplitView
├── Models/
│   ├── Task.swift                  # SwiftData TaskItem model
│   └── Category.swift              # SwiftData Category model
├── Views/
│   ├── Sidebar/
│   │   ├── SidebarView.swift       # Category list sidebar
│   │   └── CategoryRow.swift       # Category list item
│   ├── Tasks/
│   │   ├── TaskListView.swift      # Task list with filtering
│   │   ├── TaskRow.swift           # Individual task row
│   │   ├── AddTaskField.swift      # New task input
│   │   └── TaskContextMenu.swift   # Task context menu
│   ├── Category/
│   │   ├── NewCategorySheet.swift  # Category creation wizard
│   │   └── CategoryContextMenu.swift
│   ├── Settings/
│   │   └── SettingsView.swift      # Preferences
│   ├── About/
│   │   └── AboutView.swift         # About window
│   └── WelcomeView.swift           # First launch welcome
├── Utilities/
│   ├── Constants.swift             # App constants
│   └── DateFormatters.swift        # Date formatting
└── Resources/
    └── Assets.xcassets             # App icon and colors
```

## Building

1. Open `PurpleTaskMac.xcodeproj` in Xcode
2. Select the `PurpleTaskMac` scheme
3. Build and run (Cmd+R)

Or build from the command line:
```bash
xcodebuild -scheme PurpleTaskMac build
```

## Testing

```bash
xcodebuild -scheme PurpleTaskMac test
```

## Data Storage

The app uses SwiftData for persistence. Data is stored in the app's container:
`~/Library/Containers/com.purpletask.mac/Data/`

## Settings

- **Language**: English, German, French, Polish, Danish, Filipino
- **Theme**: Light, Dark, or System
- **Time Format**: 12-hour or 24-hour
- **Date Format**: Various format options
- **Show Completion Time**: Toggle task completion timestamps

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd+N | New Task |
| Cmd+Shift+N | New Category |
| Cmd+, | Open Settings |

## License

MIT License
